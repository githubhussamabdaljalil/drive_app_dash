import 'package:driver_app_dash/features/owner/data/models/owner_reports_model.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/api/api_client.dart';


class OwnerReportsRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // ===========================================================================
  // GET REPORTS
  // ===========================================================================

  Future<List<OwnerReportModel>> getReports({
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, String>{};

    if (companyId != null) {
      params['company_id'] = companyId.toString();
    }

    if (dateFrom != null && dateFrom.isNotEmpty) {
      params['date_from'] = dateFrom;
    }

    if (dateTo != null && dateTo.isNotEmpty) {
      params['date_to'] = dateTo;
    }

    final query = Uri(queryParameters: params).query;

    final path = query.isEmpty
        ? '/admin/owner/reports'
        : '/admin/owner/reports?$query';

    final response = await _api.get(path);

    // API:
    // {
    //   "data": [...],
    //   "meta": {...}
    // }

    final data = response['data'];

    if (data is! List) {
      throw Exception('بيانات التقارير غير صالحة');
    }

    return data
        .map(
          (item) => OwnerReportModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // EXPORT REPORT
  // ===========================================================================

  Future<http.Response> exportReports({
    required String format,
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, String>{
      'format': format,
    };

    if (companyId != null) {
      params['company_id'] = companyId.toString();
    }

    if (dateFrom != null && dateFrom.isNotEmpty) {
      params['date_from'] = dateFrom;
    }

    if (dateTo != null && dateTo.isNotEmpty) {
      params['date_to'] = dateTo;
    }

    final query = Uri(queryParameters: params).query;

    return _api.getBytes(
      '/admin/owner/reports/export?$query',
    );
  }
}