import '../../../../core/services/api/api_client.dart' show ApiClient, ApiException;
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
  //
  // BUGFIX: this used to do `res['data'] as List? ?? []` and swallow any
  // mismatch (wrong envelope key, nested shape, etc.) into a silent empty
  // list. No exception was thrown, so the cubit emitted a normal
  // SubManagerLoaded(..., []) — no error, no retry banner — and "Add
  // sub-manager" just stayed permanently disabled with zero feedback.
  //
  // Fix: accept the couple of envelope shapes a Laravel endpoint like this
  // realistically returns ({"data":[...]}, {"permissions":[...]}, or a bare
  // array), and if none of them yield a non-empty list, throw instead of
  // returning []. That routes the failure through the normal
  // SubManagerError path so the user sees *why* and can retry.
  Future<List<PermissionOption>> getPermissionCatalog() async {
    final res = await _api.get('/meta/permissions');

    // TEMP DEBUG — remove once confirmed working. Prints the raw decoded
    // body so you can see exactly what shape /meta/permissions returns if
    // the button is still disabled after this fix.
    // ignore: avoid_print
    print('[VTFMS] /meta/permissions raw response: $res');

    final dynamic raw = res['data'] ?? res['permissions'] ?? res['meta'];
    final List<dynamic>? list = raw is List
        ? raw
        : (raw is Map ? raw.values.toList() : null);

    if (list == null) {
      throw ApiException(
        'تعذر تحميل قائمة الصلاحيات — شكل استجابة غير متوقع من /meta/permissions',
        0,
      );
    }

    final parsed = list
        .whereType<Map>()
        .map((e) => PermissionOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (parsed.isEmpty) {
      throw ApiException(
        'قائمة الصلاحيات فارغة من السيرفر — تحقق من /meta/permissions',
        0,
      );
    }

    return parsed;
  }
}
