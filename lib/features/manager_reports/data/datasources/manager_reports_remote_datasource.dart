import '../../../../core/services/api/api_client.dart';
import '../models/manager_reports_model.dart';

/// GET /admin/manager/reports — company-scoped, Manager only.
class ManagerReportsRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<ManagerReportsModel> getReports({
    int? vehicleId,
    int? driverId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final qs = _buildQuery({
      'vehicle_id': vehicleId?.toString(),
      'driver_id': driverId?.toString(),
      'date_from': dateFrom,
      'date_to': dateTo,
    });
    final res = await _api.get('/admin/manager/reports$qs');
    return ManagerReportsModel.fromJson(res['data'] ?? res);
  }

  /// The export endpoint returns a binary file (PDF), not JSON, so it can't
  /// go through ApiClient's JSON parser. This builds the absolute,
  /// filter-aware URL for the caller to open/download directly (the
  /// backend authenticates the download via the same bearer token flow
  /// documented for `/admin/manager/reports/export`).
  String buildExportUrl({
    String format = 'pdf',
    int? vehicleId,
    int? driverId,
    String? dateFrom,
    String? dateTo,
  }) {
    final qs = _buildQuery({
      'format': format,
      'vehicle_id': vehicleId?.toString(),
      'driver_id': driverId?.toString(),
      'date_from': dateFrom,
      'date_to': dateTo,
    });
    return '${ApiClient.baseUrl}/admin/manager/reports/export$qs';
  }

  String _buildQuery(Map<String, String?> params) {
    final entries = params.entries.where((e) => e.value != null && e.value!.isNotEmpty);
    if (entries.isEmpty) return '';
    return '?${entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value!)}').join('&')}';
  }
}
