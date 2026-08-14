import '../../../../core/services/api/api_client.dart';

/// Resolves the id the manager dashboard needs to build the two socket
/// channel names from FRONTEND_QUICKSTART.md §4:
/// `private-company.{companyId}.tracking` and `private-company.{companyId}.alerts`.
///
/// Reuses the existing `GET /admin/auth/me` endpoint (already used by
/// AuthRemoteDataSource at login) instead of a new one — this file only
/// adds the company-id parsing on top, so it doesn't touch the auth feature.
class TrackingRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<int> getCompanyId() async {
    final res = await _api.get('/admin/auth/me');
    final user = res['user'] ?? res;

    // company id shape isn't documented for this endpoint — try the
    // common variants defensively (flat id, nested company object).
    final direct = user['company_id'] ?? res['company_id'];
    if (direct != null) {
      final n = num.tryParse(direct.toString());
      if (n != null) return n.toInt();
    }

    final company = user['company'] ?? res['company'];
    if (company is Map && company['id'] != null) {
      final n = num.tryParse(company['id'].toString());
      if (n != null) return n.toInt();
    }

    throw ApiException('تعذر تحديد الشركة الحالية من استجابة /admin/auth/me', 0);
  }
}
