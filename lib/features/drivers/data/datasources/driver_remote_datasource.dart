import '../../../../core/services/api/api_client.dart';
import '../models/driver_model.dart';

class DriverRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // ============================================================
  // LIST
  // ============================================================

  Future<List<DriverModel>> getDrivers({String? search, String? status}) async {
    final query = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      query.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (status != null && status.trim().isNotEmpty) {
      query.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }
    final qs = query.isEmpty ? '' : '?${query.join('&')}';

    final res = await _api.get('/admin/manager/drivers$qs');

    final list = res['data'] as List? ?? [];
    return list.map((e) => DriverModel.fromJson(e)).toList();
  }

  // ============================================================
  // CREATE
  // ============================================================
  //
  // Response includes a one-time `temporary_password` — the caller
  // (cubit) surfaces it via the raw response, not through DriverModel.

  Future<Map<String, dynamic>> createDriver(Map<String, dynamic> body) async {
    final res = await _api.post('/admin/manager/drivers', body);
    return res;
  }

  // ============================================================
  // UPDATE
  // ============================================================
  //
  // All fields optional: name, phone, email, status.

  Future<DriverModel> updateDriver(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('/admin/manager/drivers/$id', body);
    return DriverModel.fromJson(res['data'] ?? res);
  }

  // ============================================================
  // DELETE (soft delete)
  // ============================================================

  Future<void> deleteDriver(int id) async {
    await _api.delete('/admin/manager/drivers/$id');
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================
  //
  // Rotates a fresh one-time `temporary_password`, forces change on
  // next login, revokes existing tokens.

  Future<Map<String, dynamic>> resetPassword(int id) async {
    final res = await _api.post('/admin/manager/drivers/$id/reset-password', {});
    return res;
  }
}
