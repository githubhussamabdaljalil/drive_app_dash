import '../../../../core/services/api/api_client.dart';
import '../models/user_model.dart';

/// ─── Admin Auth  POST /admin/auth/*
/// ─── Driver Auth POST /driver/auth/*
class AuthRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  // ══ ADMIN ════════════════════════════════════════════════════════════

  /// POST /admin/auth/login  →  {token, user:{role:'owner'|'manager'...}}
  Future<Map<String, dynamic>> adminLogin(String email, String password) =>
      _api.post('/admin/auth/login', {
        'email': email,
        'password': password,
      }, auth: false);

  /// POST /admin/auth/verify-totp  (2FA step 2)
  Future<Map<String, dynamic>> adminVerifyTotp(
          String challengeToken, String code) =>
      _api.post('/admin/auth/verify-totp', {
        'challenge_token': challengeToken,
        'code': code,
      }, auth: false);

  /// POST /admin/auth/change-password
  Future<Map<String, dynamic>> adminChangePassword(
          String current, String newPass) =>
      _api.post('/admin/auth/change-password', {
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': newPass,
      });

  /// POST /admin/auth/forgot-password
  Future<Map<String, dynamic>> adminForgotPassword(String email) =>
      _api.post('/admin/auth/forgot-password', {'email': email}, auth: false);

  /// POST /admin/auth/verify-reset-code
  Future<Map<String, dynamic>> adminVerifyResetCode(
          String email, String code) =>
      _api.post('/admin/auth/verify-reset-code',
          {'email': email, 'code': code}, auth: false);

  /// POST /admin/auth/reset-password
  Future<Map<String, dynamic>> adminResetPassword(
          String email, String code, String newPass) =>
      _api.post('/admin/auth/reset-password', {
        'email': email,
        'code': code,
        'new_password': newPass,
        'new_password_confirmation': newPass,
      }, auth: false);

  /// GET /admin/auth/me
  Future<Map<String, dynamic>> adminMe() => _api.get('/admin/auth/me');

  /// POST /admin/auth/logout
  Future<void> adminLogout() => _api.post('/admin/auth/logout', {});

  // ══ DRIVER ═══════════════════════════════════════════════════════════

  /// POST /driver/auth/login  →  {token, requires_otp, user}
  Future<Map<String, dynamic>> driverLogin(String phone, String password) =>
      _api.post('/driver/auth/login', {
        'phone': phone,
        'password': password,
      }, auth: false);

  /// POST /driver/auth/verify-otp
  Future<Map<String, dynamic>> driverVerifyOtp(String phone, String code) =>
      _api.post('/driver/auth/verify-otp',
          {'phone': phone, 'code': code}, auth: false);

  /// GET /driver/auth/me  (profile + company + vehicle)
  Future<Map<String, dynamic>> driverMe() => _api.get('/driver/auth/me');

  /// POST /driver/auth/change-password
  Future<Map<String, dynamic>> driverChangePassword(
          String current, String newPass) =>
      _api.post('/driver/auth/change-password', {
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': newPass,
      });

  /// POST /driver/auth/logout
  Future<void> driverLogout() => _api.post('/driver/auth/logout', {});
}
