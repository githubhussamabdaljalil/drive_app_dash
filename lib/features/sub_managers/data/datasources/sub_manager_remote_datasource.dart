import '../../../../core/services/api/api_client.dart';
import '../models/sub_manager_model.dart';

class SubManagerRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<SubManagerModel>> getSubManagers({bool includeDeleted = false}) async {
    final qs = includeDeleted ? '?include_deleted=1' : '';
    final res = await _api.get('/admin/manager/sub-managers$qs');
    final list = res['data'] as List? ?? [];
    return list.map((e) => SubManagerModel.fromJson(e)).toList();
  }

  // Permissions must be a subset of the creating Manager's own permissions
  // (valid values from GET /meta/permissions). Response includes a
  // one-time temporary_password.
  Future<Map<String, dynamic>> createSubManager(Map<String, dynamic> body) async {
    return _api.post('/admin/manager/sub-managers', body);
  }

  Future<SubManagerModel> updateSubManager(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('/admin/manager/sub-managers/$id', body);
    return SubManagerModel.fromJson(res['data'] ?? res);
  }

  // Replaces the full permission set.
  Future<SubManagerModel> updatePermissions(int id, List<String> permissions) async {
    final res = await _api.patch('/admin/manager/sub-managers/$id/permissions', {'permissions': permissions});
    return SubManagerModel.fromJson(res['data'] ?? res);
  }

  Future<void> deleteSubManager(int id) async {
    await _api.delete('/admin/manager/sub-managers/$id');
  }

  // Static catalog — no auth required.
  Future<List<PermissionOption>> getPermissionCatalog() async {
    final res = await _api.get('/meta/permissions');
    final list = res['data'] as List? ?? [];
    return list.map((e) => PermissionOption.fromJson(e)).toList();
  }
}
