import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ws_config.dart';
import '../../../../core/services/realtime/reverb_socket_service.dart';
import '../../data/datasources/tracking_remote_datasource.dart';
import '../../data/models/live_sos_alert_model.dart';
import '../../data/models/vehicle_location_model.dart';

part 'tracking_state.dart';

/// Manager's live map — FRONTEND_QUICKSTART.md §4:
/// subscribes `private-company.{id}.tracking` for `location.updated` and
/// `private-company.{id}.alerts` for `sos.triggered`. Purely a listener:
/// the manager dashboard never whispers, only drivers do.
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit() : super(TrackingInitial());

  final TrackingRemoteDataSource _ds = TrackingRemoteDataSource();

  ReverbSocketService? _socket;

  final Map<int, VehicleLocationModel> _locations = {};
  final List<LiveSosAlertModel> _alerts = [];

  bool _starting = false;

  Future<void> start() async {
    if (isClosed) return;

    // Prevent multiple start() calls from creating multiple sockets.
    if (_starting) return;

    _starting = true;

    try {
      // ----------------------------------------------------------------------
      // Clean up any previous socket before starting a new realtime session.
      // ----------------------------------------------------------------------

      _socket?.dispose();
      _socket = null;

      // Clear old live data when starting a fresh session.
      _locations.clear();
      _alerts.clear();

      if (!isClosed) {
        emit(TrackingLoading());
      }

      // ----------------------------------------------------------------------
      // Get manager company ID.
      // ----------------------------------------------------------------------

      int companyId;

      try {
        companyId = await _ds.getCompanyId();
      } catch (e) {
        if (!isClosed) {
          emit(TrackingError(e.toString()));
        }

        return;
      }

      if (isClosed) return;

      // ----------------------------------------------------------------------
      // Create socket.
      // ----------------------------------------------------------------------

      ReverbSocketService? newSocket;

      newSocket = ReverbSocketService(
        wsHost: WsConfig.host,
        wsPort: WsConfig.port,
        useTLS: WsConfig.tls,
        appKey: WsConfig.appKey,
        onStatusChange: (s) {
          // Ignore callbacks from an old socket.
          if (_socket != newSocket) return;

          if (!isClosed) {
            _emit(connection: s);
          }
        },
      );

      _socket = newSocket;

      // ----------------------------------------------------------------------
      // Tracking channel
      // ----------------------------------------------------------------------

      newSocket.subscribePrivate('private-company.$companyId.tracking', {
        'location.updated': (data) {
          // Ignore events from an old socket.
          if (_socket != newSocket) return;

          try {
            final loc = VehicleLocationModel.fromJson(data);

            if (loc.vehicleId == 0) return;

            _locations[loc.vehicleId] = loc;

            if (!isClosed) {
              _emit();
            }
          } catch (e) {
            // ignore: avoid_print
            print('[TrackingCubit] Failed to parse location.updated: $e');
          }
        },
      });

      // ----------------------------------------------------------------------
      // Alerts channel
      // ----------------------------------------------------------------------

      newSocket.subscribePrivate('private-company.$companyId.alerts', {
        'sos.triggered': (data) {
          // Ignore events from an old socket.
          if (_socket != newSocket) return;

          try {
            final alert = LiveSosAlertModel.fromJson(data);

            // Re-alert replaces the existing alert instead of duplicating it.
            _alerts.removeWhere((a) => a.id == alert.id);

            _alerts.insert(0, alert);

            // Keep only the latest 30 alerts.
            if (_alerts.length > 30) {
              _alerts.removeRange(30, _alerts.length);
            }

            if (!isClosed) {
              _emit();
            }
          } catch (e) {
            // ignore: avoid_print
            print('[TrackingCubit] Failed to parse sos.triggered: $e');
          }
        },
      });

      // ----------------------------------------------------------------------
      // Connect
      // ----------------------------------------------------------------------

      newSocket.connect();
    } finally {
      _starting = false;
    }
  }

  // ==========================================================================
  // DISMISS ALERT
  // ==========================================================================

  void dismissAlert(int id) {
    _alerts.removeWhere((a) => a.id == id);

    if (!isClosed) {
      _emit();
    }
  }

  // ==========================================================================
  // EMIT CURRENT STATE
  // ==========================================================================

  void _emit({RealtimeStatus? connection}) {
    if (isClosed) return;

    emit(
      TrackingReady(
        connection:
            connection ?? _socket?.status ?? RealtimeStatus.disconnected,
        locations: Map.unmodifiable(_locations),
        activeAlerts: List.unmodifiable(_alerts),
      ),
    );
  }

  // ==========================================================================
  // CLOSE
  // ==========================================================================

  @override
  Future<void> close() {
    _starting = false;

    _socket?.dispose();
    _socket = null;

    _locations.clear();
    _alerts.clear();

    return super.close();
  }
}
