import '../../../../core/services/api/api_client.dart';
import '../models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // ============================================================
  // LIST
  // ============================================================

  Future<List<VehicleModel>> getVehicles({
    String? search,
    String? status,
    bool includeDeleted = false,
  }) async {
    final query = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      query.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (status != null && status.trim().isNotEmpty) {
      query.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }
    if (includeDeleted) {
      query.add('include_deleted=1');
    }
    final qs = query.isEmpty ? '' : '?${query.join('&')}';

    final res = await _api.get('/admin/manager/vehicles$qs');

    final list = res['data'] as List? ?? [];
    return list.map((e) => VehicleModel.fromJson(e)).toList();
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<VehicleModel> createVehicle(Map<String, dynamic> body) async {
    final res = await _api.post('/admin/manager/vehicles', body);
    return VehicleModel.fromJson(res['data'] ?? res);
  }

  // ============================================================
  // UPDATE
  // ============================================================
  //
  // `status` (if sent) only accepts "maintenance" or "out_of_service".
  // active/inactive are computed automatically by the server and are
  // rejected (422) if sent here.

  Future<VehicleModel> updateVehicle(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('/admin/manager/vehicles/$id', body);
    return VehicleModel.fromJson(res['data'] ?? res);
  }

  // ============================================================
  // DELETE (soft delete)
  // ============================================================

  Future<void> deleteVehicle(int id) async {
    await _api.delete('/admin/manager/vehicles/$id');
  }
}
