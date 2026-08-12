import '../../../../core/services/api/api_client.dart';
import '../models/company_model.dart';

class CompanyRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<CompanyModel>> getCompanies() async {
    final res = await _api.get(
      '/admin/owner/companies',
    );

    final list = res['data'] as List? ?? [];

    return list
        .map(
          (e) => CompanyModel.fromJson(e),
        )
        .toList();
  }

  Future<CompanyModel> createCompany(
    Map<String, dynamic> body,
  ) async {
    final res = await _api.post(
      '/admin/owner/companies',
      body,
    );

    return CompanyModel.fromJson(
      res['data'] ?? res,
    );
  }

  Future<CompanyModel> updateCompany(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await _api.patch(
      '/admin/owner/companies/$id',
      body,
    );

    return CompanyModel.fromJson(
      res['data'] ?? res,
    );
  }

  Future<void> deleteCompany(int id) async {
    await _api.delete(
      '/admin/owner/companies/$id',
    );
  }

  Future<CompanyModel> activateCompany(int id) async {
    final res = await _api.patch(
      '/admin/owner/companies/$id/activate',
      {},
    );

    return CompanyModel.fromJson(
      res['data'] ?? res,
    );
  }

  Future<CompanyModel> deactivateCompany(int id) async {
    final res = await _api.patch(
      '/admin/owner/companies/$id/deactivate',
      {},
    );

    return CompanyModel.fromJson(
      res['data'] ?? res,
    );
  }
}