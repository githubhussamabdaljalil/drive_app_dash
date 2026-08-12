import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/models/driver_model.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final DriverRemoteDataSource _ds = DriverRemoteDataSource();

  DriverCubit() : super(DriverInitial());

  Future<void> load() async {
    if (isClosed) return;
    emit(DriverLoading());
    try {
      final list = await _ds.getDrivers();
      if (!isClosed) emit(DriverLoaded(list));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString()));
    }
  }

  Future<void> create(Map<String, dynamic> body) async {
    if (isClosed) return;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      final driver = await _ds.createDriver(body);
      if (!isClosed) emit(DriverLoaded([...current, driver]));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
    }
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    if (isClosed) return;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      final updated = await _ds.updateDriver(id, body);
      if (!isClosed) emit(DriverLoaded(current.map((d) => d.id == id ? updated : d).toList()));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
    }
  }

  Future<void> toggleStatus(DriverModel driver) async {
    if (isClosed) return;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      final updated = driver.isActive
          ? await _ds.deactivateDriver(driver.id)
          : await _ds.activateDriver(driver.id);
      if (!isClosed) emit(DriverLoaded(current.map((d) => d.id == driver.id ? updated : d).toList()));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
    }
  }

  Future<void> delete(int id) async {
    if (isClosed) return;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      await _ds.deleteDriver(id);
      if (!isClosed) emit(DriverLoaded(current.where((d) => d.id != id).toList()));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
    }
  }

  List<DriverModel> get _currentList {
    final s = state;
    if (s is DriverLoaded) return s.drivers;
    if (s is DriverSubmitting) return s.drivers;
    if (s is DriverError) return s.drivers ?? [];
    return [];
  }
}
