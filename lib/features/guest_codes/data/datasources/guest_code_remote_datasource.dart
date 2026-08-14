import '../../../../core/services/api/api_client.dart';
import '../models/guest_code_model.dart';

class GuestCodeRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<GuestCodeModel>> getGuestCodes({String? status}) async {
    final qs = (status != null && status.trim().isNotEmpty) ? '?status=${Uri.encodeQueryComponent(status.trim())}' : '';
    final res = await _api.get('/admin/manager/guest-codes$qs');
    final list = res['data'] as List? ?? [];
    return list.map((e) => GuestCodeModel.fromJson(e)).toList();
  }

  // expiresInMinutes: 1-1440.
  Future<GuestCodeModel> createGuestCode({required int vehicleId, required int expiresInMinutes}) async {
    final res = await _api.post('/admin/manager/guest-codes', {
      'vehicle_id': vehicleId,
      'expires_in_minutes': expiresInMinutes,
    });
    return GuestCodeModel.fromJson(res['data'] ?? res);
  }

  Future<void> revokeGuestCode(int id) async {
    await _api.delete('/admin/manager/guest-codes/$id');
  }
}
