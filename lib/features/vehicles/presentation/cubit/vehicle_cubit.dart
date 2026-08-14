import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/models/vehicle_model.dart';

part 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRemoteDataSource _ds = VehicleRemoteDataSource();

  VehicleCubit() : super(VehicleInitial());

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load({String? search, String? status}) async {
    if (isClosed) return;
    emit(VehicleLoading());
    try {
      final list = await _ds.getVehicles(search: search, status: status);
      if (!isClosed) emit(VehicleLoaded(list));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString()));
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<bool> create(Map<String, dynamic> body) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      await _ds.createVehicle(body);
      final list = await _ds.getVehicles();
      if (!isClosed) emit(VehicleLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
      return false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> update(int id, Map<String, dynamic> body) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      await _ds.updateVehicle(id, body);
      final list = await _ds.getVehicles();
      if (!isClosed) emit(VehicleLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
      return false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> delete(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      await _ds.deleteVehicle(id);
      final list = await _ds.getVehicles();
      if (!isClosed) emit(VehicleLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
      return false;
    }
  }

  List<VehicleModel> get _currentList {
    final s = state;
    if (s is VehicleLoaded) return s.vehicles;
    if (s is VehicleSubmitting) return s.vehicles;
    if (s is VehicleError) return s.vehicles ?? [];
    return [];
  }
}
