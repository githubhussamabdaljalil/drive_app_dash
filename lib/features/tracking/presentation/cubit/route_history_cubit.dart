import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/route_history_remote_datasource.dart';
import '../../data/models/route_point_model.dart';

part 'route_history_state.dart';

class RouteHistoryCubit extends Cubit<RouteHistoryState> {
  RouteHistoryCubit() : super(RouteHistoryInitial());

  final RouteHistoryRemoteDataSource _ds = RouteHistoryRemoteDataSource();

  Future<void> load({
    required int vehicleId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (isClosed) return;
    emit(RouteHistoryLoading());
    try {
      final points = await _ds.getRouteHistory(vehicleId: vehicleId, from: from, to: to);
      if (!isClosed) emit(RouteHistoryLoaded(points));
    } catch (e) {
      if (!isClosed) emit(RouteHistoryError(e.toString()));
    }
  }

  void reset() {
    if (!isClosed) emit(RouteHistoryInitial());
  }
}
