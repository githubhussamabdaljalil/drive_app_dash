import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// REQ-Auth-01 / REQ-Auth-09
  Future<UserEntity> login(String email, String password);

  /// REQ-Auth-07 / REQ-Auth-08
  Future<void> changePassword(String tempPassword, String newPassword);

  /// REQ-Auth-02: الكود يُرسل لكلا القناتين (UC-03)
  Future<void> sendResetCode(String email);

  /// UC-03: التحقق من الكود
  Future<void> verifyResetCode(String code);

  /// UC-03: حفظ كلمة المرور الجديدة
  Future<void> saveNewPassword(String newPassword);

  /// REQ-Auth-03: تعديل بيانات الحساب الشخصي
  Future<void> updateProfile(String name);

  /// UC-02: تسجيل الخروج
  Future<void> logout();

  /// التحقق من الجلسة عند فتح التطبيق
  Future<UserEntity?> getCurrentUser();
}
