import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> changePassword(String tempPassword, String newPassword);
  Future<void> sendResetCode(String email);
  Future<void> verifyResetCode(String code);
  Future<void> saveNewPassword(String newPassword);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile(String name);
}

/// TODO: استبدل بالـ implementation الحقيقي مع Dio
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // final DioClient dioClient;
  // AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String email, String password) {
    throw UnimplementedError('TODO: POST /auth/login');
  }

  @override
  Future<void> changePassword(String tempPassword, String newPassword) {
    throw UnimplementedError('TODO: POST /auth/change-password');
  }

  @override
  Future<void> sendResetCode(String email) {
    throw UnimplementedError('TODO: POST /auth/reset-password');
  }

  @override
  Future<void> verifyResetCode(String code) {
    throw UnimplementedError('TODO: POST /auth/verify-code');
  }

  @override
  Future<void> saveNewPassword(String newPassword) {
    throw UnimplementedError('TODO: POST /auth/save-password');
  }

  @override
  Future<void> logout() {
    throw UnimplementedError('TODO: POST /auth/logout');
  }

  @override
  Future<UserModel?> getCurrentUser() {
    throw UnimplementedError('TODO: GET /auth/me');
  }

  @override
  Future<void> updateProfile(String name) {
    throw UnimplementedError('TODO: PATCH /auth/profile');
  }
}
