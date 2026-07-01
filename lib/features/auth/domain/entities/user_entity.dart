/// User Entity — بيانات المستخدم بعد تسجيل الدخول
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role;            // 'driver' (التطبيق يخص السائقين فقط)
  final bool isFirstLogin;      // REQ-Auth-07: هل كلمة المرور مؤقتة؟
  final String? linkedVehicleId; // REQ-Fleet-03: المركبة المرتبطة

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isFirstLogin,
    this.linkedVehicleId,
  });
}
