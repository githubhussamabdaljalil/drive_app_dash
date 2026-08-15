import '../../../../core/services/api/api_client.dart';

/// Admin (owner / manager) auth  —  POST /admin/auth/*
/// Driver/guest auth lives in the separate driver mobile app, not here.
class AuthRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  /// POST /admin/auth/login  →  {token, user:{role:'owner'|'manager'...}}
  Future<Map<String, dynamic>> adminLogin(String email, String password) =>
      _api.post('/admin/auth/login', {
        'email': email,
        'password': password,
      }, auth: false);

  /// POST /admin/auth/verify-totp  (2FA step 2)
  Future<Map<String, dynamic>> adminVerifyTotp(String challengeToken, String code) =>
      _api.post('/admin/auth/verify-totp', {
        'challenge_token': challengeToken,
        'code': code,
      }, auth: false);

  /// POST /admin/auth/change-password
  Future<Map<String, dynamic>> adminChangePassword(String current, String newPass) =>
      _api.post('/admin/auth/change-password', {
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': newPass,
      });

  /// POST /admin/auth/forgot-password
  Future<Map<String, dynamic>> adminForgotPassword(String email) =>
      _api.post('/admin/auth/forgot-password', {'email': email}, auth: false);

  /// POST /admin/auth/verify-reset-code
  Future<Map<String, dynamic>> adminVerifyResetCode(String email, String code) =>
      _api.post('/admin/auth/verify-reset-code', {'email': email, 'code': code}, auth: false);

  /// POST /admin/auth/reset-password
  Future<Map<String, dynamic>> adminResetPassword(String email, String code, String newPass) =>
      _api.post('/admin/auth/reset-password', {
        'email': email,
        'code': code,
        'new_password': newPass,
        'new_password_confirmation': newPass,
      }, auth: false);

  /// GET /admin/auth/me
  Future<Map<String, dynamic>> adminMe() => _api.get('/admin/auth/me');

  /// POST /admin/auth/logout
  // Future<void> adminLogout() => _api.post('/admin/auth/logout', {});
  Future<void> adminLogout() async {
  await ApiClient.instance.postEmpty(
    '/admin/auth/logout',
  );
}
}
