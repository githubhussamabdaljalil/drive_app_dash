import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ws_config.dart';
import '../../../../core/services/api/api_client.dart';
import '../../../../core/services/realtime/reverb_socket_service.dart';
import '../../data/datasources/guest_tracking_remote_datasource.dart';
import '../../data/models/guest_tracking_model.dart';

part 'guest_tracking_state.dart';

class GuestTrackingCubit extends Cubit<GuestTrackingState> {
  GuestTrackingCubit() : super(GuestTrackingInitial());

  final GuestTrackingRemoteDataSource _ds = GuestTrackingRemoteDataSource();

  ReverbSocketService? _socket;
  GuestTrackingModel? _data;

  Future<void> load(String guestCode) async {
    if (isClosed) return;

    _socket?.dispose();
    _socket = null;

    emit(GuestTrackingLoading());

    try {
      _data = await _ds.track(guestCode);

      if (isClosed) return;

      emit(GuestTrackingLoaded(data: _data!));

      _startLive(_data!.liveChannel);
    } on ApiException catch (e) {
      if (isClosed) return;

      final isExpired = e.statusCode == 404 || e.statusCode == 410;

      emit(GuestTrackingError(
        isExpired ? 'كود التتبع غير صالح أو منتهي الصلاحية' : e.message,
        isExpired: isExpired,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(GuestTrackingError(e.toString()));
    }
  }

  void _startLive(String? channel) {
    if (channel == null || channel.isEmpty) return;

    ReverbSocketService? newSocket;

    newSocket = ReverbSocketService(
      wsHost: WsConfig.host,
      wsPort: WsConfig.port,
      useTLS: WsConfig.tls,
      appKey: WsConfig.appKey,
      onStatusChange: (s) {
        if (_socket != newSocket) return;
        if (isClosed) return;
        final current = state;
        if (current is GuestTrackingLoaded) {
          emit(current.copyWith(connection: s));
        }
      },
    );

    _socket = newSocket;

    newSocket.subscribePublic(channel, {
      'location.updated': (data) {
        if (_socket != newSocket) return;
        if (isClosed) return;
        final current = state;
        if (current is! GuestTrackingLoaded) return;

        try {
          final loc = GuestLocationModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          _data = _data?.copyWithLocation(loc);
          if (_data != null) {
            emit(current.copyWith(data: _data, hasNewLocation: true));
          }
        } catch (_) {}
      },
    });

    newSocket.connect();
  }

  @override
  Future<void> close() {
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}
