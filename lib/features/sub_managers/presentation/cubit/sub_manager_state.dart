part of 'sub_manager_cubit.dart';

abstract class SubManagerState {}

class SubManagerInitial extends SubManagerState {}

class SubManagerLoading extends SubManagerState {}

class SubManagerLoaded extends SubManagerState {
  final List<SubManagerModel> subManagers;
  final List<PermissionOption> permissionCatalog;
  SubManagerLoaded(this.subManagers, this.permissionCatalog);
}

class SubManagerSubmitting extends SubManagerState {
  final List<SubManagerModel> subManagers;
  final List<PermissionOption> permissionCatalog;
  SubManagerSubmitting(this.subManagers, this.permissionCatalog);
}

class SubManagerError extends SubManagerState {
  final String message;
  final List<SubManagerModel> subManagers;
  final List<PermissionOption> permissionCatalog;
  SubManagerError(this.message, [this.subManagers = const [], this.permissionCatalog = const []]);
}
