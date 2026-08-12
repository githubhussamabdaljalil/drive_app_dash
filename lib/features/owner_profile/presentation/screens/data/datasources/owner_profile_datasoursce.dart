import '../../../../../../core/services/api/api_client.dart';
import '../../models/profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<ProfileModel> getProfile() async {
    final res = await _api.get('/admin/auth/me');

    final user = res['user'] as Map<String, dynamic>;

    return ProfileModel.fromJson(user);
  }
}