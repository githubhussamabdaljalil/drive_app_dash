import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/models/driver_model.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final DriverRemoteDataSource _ds = DriverRemoteDataSource();

  DriverCubit() : super(DriverInitial());

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load({String? search, String? status}) async {
    if (isClosed) return;
    emit(DriverLoading());
    try {
      final list = await _ds.getDrivers(search: search, status: status);
      if (!isClosed) emit(DriverLoaded(list));
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString()));
    }
  }

  // ============================================================
  // CREATE
  // ============================================================
  //
  // Returns the one-time temporary_password on success (null on
  // failure) so the UI can show it to the manager once.

  Future<String?> create(Map<String, dynamic> body) async {
    if (isClosed) return null;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      final res = await _ds.createDriver(body);
      final tempPassword = res['temporary_password']?.toString();
      final list = await _ds.getDrivers();
      if (!isClosed) emit(DriverLoaded(list));
      return tempPassword ?? '';
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
      return null;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<bool> update(int id, Map<String, dynamic> body) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      await _ds.updateDriver(id, body);
      final list = await _ds.getDrivers();
      if (!isClosed) emit(DriverLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
      return false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<bool> delete(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      await _ds.deleteDriver(id);
      final list = await _ds.getDrivers();
      if (!isClosed) emit(DriverLoaded(list));
      return true;
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
      return false;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================
  //
  // Returns the new one-time temporary_password on success.

  Future<String?> resetPassword(int id) async {
    if (isClosed) return null;
    final current = _currentList;
    emit(DriverSubmitting(current));
    try {
      final res = await _ds.resetPassword(id);
      final tempPassword = res['temporary_password']?.toString() ?? '';
      if (!isClosed) emit(DriverLoaded(current));
      return tempPassword;
    } catch (e) {
      if (!isClosed) emit(DriverError(e.toString(), current));
      return null;
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
