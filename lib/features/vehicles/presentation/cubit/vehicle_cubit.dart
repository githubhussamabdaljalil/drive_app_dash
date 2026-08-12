import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/models/vehicle_model.dart';

part 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRemoteDataSource _ds = VehicleRemoteDataSource();

  VehicleCubit() : super(VehicleInitial());

  Future<void> load() async {
    if (isClosed) return;
    emit(VehicleLoading());
    try {
      final list = await _ds.getVehicles();
      if (!isClosed) emit(VehicleLoaded(list));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString()));
    }
  }

  Future<void> create(Map<String, dynamic> body) async {
    if (isClosed) return;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      final vehicle = await _ds.createVehicle(body);
      if (!isClosed) emit(VehicleLoaded([...current, vehicle]));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
    }
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    if (isClosed) return;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      final updated = await _ds.updateVehicle(id, body);
      if (!isClosed) emit(VehicleLoaded(current.map((v) => v.id == id ? updated : v).toList()));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
    }
  }

  Future<void> toggleStatus(VehicleModel vehicle) async {
    if (isClosed) return;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      final updated = vehicle.isActive
          ? await _ds.deactivateVehicle(vehicle.id)
          : await _ds.activateVehicle(vehicle.id);
      if (!isClosed) emit(VehicleLoaded(current.map((v) => v.id == vehicle.id ? updated : v).toList()));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
    }
  }

  Future<void> delete(int id) async {
    if (isClosed) return;
    final current = _currentList;
    emit(VehicleSubmitting(current));
    try {
      await _ds.deleteVehicle(id);
      if (!isClosed) emit(VehicleLoaded(current.where((v) => v.id != id).toList()));
    } catch (e) {
      if (!isClosed) emit(VehicleError(e.toString(), current));
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
