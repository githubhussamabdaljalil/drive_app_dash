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

  Future<void> start() async {
    if (isClosed) return;
    emit(TrackingLoading());

    int companyId;
    try {
      companyId = await _ds.getCompanyId();
    } catch (e) {
      if (!isClosed) emit(TrackingError(e.toString()));
      return;
    }

    _socket = ReverbSocketService(
      wsHost: WsConfig.host,
      wsPort: WsConfig.port,
      useTLS: WsConfig.tls,
      appKey: WsConfig.appKey,
      onStatusChange: (s) {
        if (!isClosed) _emit(connection: s);
      },
    );

    _socket!.subscribePrivate('private-company.$companyId.tracking', {
      'location.updated': (data) {
        final loc = VehicleLocationModel.fromJson(data);
        if (loc.vehicleId == 0) return;
        _locations[loc.vehicleId] = loc;
        if (!isClosed) _emit();
      },
    });

    _socket!.subscribePrivate('private-company.$companyId.alerts', {
      'sos.triggered': (data) {
        final alert = LiveSosAlertModel.fromJson(data);
        _alerts.removeWhere((a) => a.id == alert.id); // re-alert replaces, doesn't duplicate
        _alerts.insert(0, alert);
        if (_alerts.length > 30) _alerts.removeRange(30, _alerts.length);
        if (!isClosed) _emit();
      },
    });

    _socket!.connect();
  }

  void dismissAlert(int id) {
    _alerts.removeWhere((a) => a.id == id);
    if (!isClosed) _emit();
  }

  void _emit({RealtimeStatus? connection}) {
    emit(TrackingReady(
      connection: connection ?? _socket?.status ?? RealtimeStatus.disconnected,
      locations: Map.unmodifiable(_locations),
      activeAlerts: List.unmodifiable(_alerts),
    ));
  }

  @override
  Future<void> close() {
    _socket?.dispose();
    return super.close();
  }
}
