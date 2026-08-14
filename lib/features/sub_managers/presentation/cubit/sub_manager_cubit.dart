import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/sub_manager_remote_datasource.dart';
import '../../data/models/sub_manager_model.dart';

part 'sub_manager_state.dart';

class SubManagerCubit extends Cubit<SubManagerState> {
  final SubManagerRemoteDataSource _ds = SubManagerRemoteDataSource();

  SubManagerCubit() : super(SubManagerInitial());

  // Loads both the sub-manager list and the static permission catalog
  // (the checkbox matrix needs both).
  //
  // BUGFIX: this used to run both requests via Future.wait and emit a
  // single SubManagerError(...) — with its default empty permissionCatalog
  // — the moment EITHER call failed. A transient failure on just the
  // sub-managers list (network blip, 401 mid-session, etc.) silently wiped
  // the permission catalog too, and since "Add sub-manager" is disabled
  // whenever the catalog is empty, the button stayed permanently greyed
  // out until the app was restarted. It was never a permissions/role
  // issue — /meta/permissions is a public, static catalog.
  //
  // Fix: fetch them independently so one failing doesn't blank the other,
  // and keep whatever catalog we already have on a retry instead of
  // resetting it to [].
  Future<void> load() async {
    if (isClosed) return;
    final keepCatalog = _currentCatalog;
    emit(SubManagerLoading());

    List<SubManagerModel>? list;
    List<PermissionOption>? catalog;
    Object? firstError;

    try {
      list = await _ds.getSubManagers();
    } catch (e) {
      firstError = e;
    }

    try {
      catalog = await _ds.getPermissionCatalog();
    } catch (e) {
      firstError ??= e;
    }
    if (isClosed) return;

    if (firstError != null) {
      emit(SubManagerError(
        firstError.toString(),
        list ?? const [],
        catalog ?? keepCatalog,
      ));
      return;
    }

    emit(SubManagerLoaded(list!, catalog!));
  }

  // Returns the one-time temporary_password on success.
  Future<String?> create(Map<String, dynamic> body) async {
    if (isClosed) return null;
    final current = _currentList;
    final catalog = _currentCatalog;
    emit(SubManagerSubmitting(current, catalog));
    try {
      final res = await _ds.createSubManager(body);
      final tempPassword = res['temporary_password']?.toString() ?? '';
      final list = await _ds.getSubManagers();
      if (!isClosed) emit(SubManagerLoaded(list, catalog));
      return tempPassword;
    } catch (e) {
      if (!isClosed) emit(SubManagerError(e.toString(), current, catalog));
      return null;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    if (isClosed) return false;
    final current = _currentList;
    final catalog = _currentCatalog;
    emit(SubManagerSubmitting(current, catalog));
    try {
      await _ds.updateSubManager(id, body);
      final list = await _ds.getSubManagers();
      if (!isClosed) emit(SubManagerLoaded(list, catalog));
      return true;
    } catch (e) {
      if (!isClosed) emit(SubManagerError(e.toString(), current, catalog));
      return false;
    }
  }

  Future<bool> updatePermissions(int id, List<String> permissions) async {
    if (isClosed) return false;
    final current = _currentList;
    final catalog = _currentCatalog;
    emit(SubManagerSubmitting(current, catalog));
    try {
      await _ds.updatePermissions(id, permissions);
      final list = await _ds.getSubManagers();
      if (!isClosed) emit(SubManagerLoaded(list, catalog));
      return true;
    } catch (e) {
      if (!isClosed) emit(SubManagerError(e.toString(), current, catalog));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    if (isClosed) return false;
    final current = _currentList;
    final catalog = _currentCatalog;
    emit(SubManagerSubmitting(current, catalog));
    try {
      await _ds.deleteSubManager(id);
      final list = await _ds.getSubManagers();
      if (!isClosed) emit(SubManagerLoaded(list, catalog));
      return true;
    } catch (e) {
      if (!isClosed) emit(SubManagerError(e.toString(), current, catalog));
      return false;
    }
  }

  List<SubManagerModel> get _currentList {
    final s = state;
    if (s is SubManagerLoaded) return s.subManagers;
    if (s is SubManagerSubmitting) return s.subManagers;
    if (s is SubManagerError) return s.subManagers;
    return [];
  }

  List<PermissionOption> get _currentCatalog {
    final s = state;
    if (s is SubManagerLoaded) return s.permissionCatalog;
    if (s is SubManagerSubmitting) return s.permissionCatalog;
    if (s is SubManagerError) return s.permissionCatalog;
    return [];
  }
}
