import '../../../../core/services/api/api_client.dart';
import '../models/owner_statistics_model.dart';

class OwnerRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // ══════════════════════════════════════════════════════════════════════════
  // Statistics API
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /admin/owner/statistics
  /// Returns platform-level statistics for Owner
  Future<OwnerStatisticsModel> getStatistics() async {
    final res = await _api.get('/admin/owner/statistics');
    return OwnerStatisticsModel.fromJson(res['data'] ?? res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Companies API (Already exists in CompanyRemoteDataSource)
  // ══════════════════════════════════════════════════════════════════════════
  // Note: Company CRUD operations are handled by CompanyRemoteDataSource
  // located in lib/features/companies/data/datasources/

  /// GET /admin/owner/companies/{id}
  /// Returns detailed information about a specific company
  Future<Map<String, dynamic>> getCompanyDetails(int id) async {
    final res = await _api.get('/admin/owner/companies/$id');
    return res['data'] ?? res;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Reports API
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /admin/owner/reports
  /// Returns platform-wide reports with optional filters
  ///
  /// Parameters:
  /// - [companyId]: Optional company filter
  /// - [dateFrom]: Optional start date (YYYY-MM-DD)
  /// - [dateTo]: Optional end date (YYYY-MM-DD)
  Future<Map<String, dynamic>> getReports({
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, String>{};
    if (companyId != null) params['company_id'] = companyId.toString();
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final res = await _api.get('/admin/owner/reports$query');
    return res['data'] ?? res;
  }

  /// GET /admin/owner/reports/export
  /// Exports reports as PDF or Excel file
  ///
  /// Parameters:
  /// - [format]: Required - 'pdf' or 'excel'
  /// - [companyId]: Optional company filter
  /// - [dateFrom]: Optional start date (YYYY-MM-DD)
  /// - [dateTo]: Optional end date (YYYY-MM-DD)
  ///
  /// Returns: Raw bytes of the file
  Future<List<int>> exportReport({
    required String format,
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, String>{'format': format};
    if (companyId != null) params['company_id'] = companyId.toString();
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final query =
        '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    // This endpoint returns a file, not JSON
    // TODO: Implement binary file download in ApiClient
    throw UnimplementedError(
      'File download not yet implemented in ApiClient. '
      'Endpoint: GET /admin/owner/reports/export$query',
    );
  }
}
