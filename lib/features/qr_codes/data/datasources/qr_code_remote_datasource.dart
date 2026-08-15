import '../../../../core/services/api/api_client.dart';
import '../models/qr_code_model.dart';

class QrCodeRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // Returns null if the vehicle has no active code yet (server returns 404).
  Future<QrCodeModel?> getQrCode(int vehicleId) async {
    try {
      final res = await _api.get('/admin/manager/vehicles/$vehicleId/qr-code');
      return QrCodeModel.fromJson(res['qr_code'] ?? res['data'] ?? res);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // Generates a new 12-char active code. If one already exists it is
  // atomically invalidated (status=reset) in the same transaction.
  Future<QrCodeModel> generateQrCode(int vehicleId) async {
    final res = await _api.post('/admin/manager/vehicles/$vehicleId/qr-code', {});
    return QrCodeModel.fromJson(res['qr_code'] ?? res['data'] ?? res);
  }

  // Revokes the active code without replacing it (status=deleted).
  Future<void> revokeQrCode(int vehicleId) async {
    await _api.delete('/admin/manager/vehicles/$vehicleId/qr-code');
  }
}
