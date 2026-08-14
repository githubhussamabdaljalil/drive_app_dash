import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/destination_remote_datasource.dart';
import '../../data/models/destination_model.dart';

part 'destination_state.dart';

class DestinationCubit extends Cubit<DestinationState> {
  final DestinationRemoteDataSource _ds = DestinationRemoteDataSource();

  DestinationCubit() : super(DestinationInitial());

  Future<void> load({String? status}) async {
    if (isClosed) return;
    emit(DestinationLoading());
    try {
      final list = await _ds.getDestinations(status: status);
      if (!isClosed) emit(DestinationLoaded(list));
    } catch (e) {
      if (!isClosed) emit(DestinationError(e.toString()));
    }
  }

  Future<bool> create({int? driverId, int? vehicleId, required double targetLat, required double targetLng}) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(DestinationSubmitting(current));
    try {
      await _ds.createDestination(driverId: driverId, vehicleId: vehicleId, targetLat: targetLat, targetLng: targetLng);
      final list = await _ds.getDestinations();
      if (!isClosed) emit(DestinationLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(DestinationError(e.toString(), current));
      return false;
    }
  }

  Future<bool> update(int id, {int? driverId, int? vehicleId, double? targetLat, double? targetLng}) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(DestinationSubmitting(current));
    try {
      await _ds.updateDestination(id, driverId: driverId, vehicleId: vehicleId, targetLat: targetLat, targetLng: targetLng);
      final list = await _ds.getDestinations();
      if (!isClosed) emit(DestinationLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(DestinationError(e.toString(), current));
      return false;
    }
  }

  Future<bool> cancel(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(DestinationSubmitting(current));
    try {
      await _ds.cancelDestination(id);
      final list = await _ds.getDestinations();
      if (!isClosed) emit(DestinationLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(DestinationError(e.toString(), current));
      return false;
    }
  }

  List<DestinationModel> get _currentList {
    final s = state;
    if (s is DestinationLoaded) return s.destinations;
    if (s is DestinationSubmitting) return s.destinations;
    if (s is DestinationError) return s.destinations ?? [];
    return [];
  }
}
