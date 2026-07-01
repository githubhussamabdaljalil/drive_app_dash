part of 'auth_bloc.dart';

abstract class AuthEvent {}

/// تسجيل الدخول (REQ-Auth-01, REQ-Auth-09)
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

/// تغيير كلمة المرور الإجباري (REQ-Auth-07, REQ-Auth-08)
class ChangePasswordRequested extends AuthEvent {
  final String tempPassword;
  final String newPassword;
  ChangePasswordRequested(this.tempPassword, this.newPassword);
}

/// إعادة تعيين كلمة المرور (REQ-Auth-02)
class ResetPasswordRequested extends AuthEvent {
  final String email;
  ResetPasswordRequested(this.email);
}

/// التحقق من كود الإعادة (UC-03)
class VerifyResetCodeRequested extends AuthEvent {
  final String code;
  VerifyResetCodeRequested(this.code);
}

/// حفظ كلمة المرور الجديدة بعد الـ reset
class SaveNewPasswordRequested extends AuthEvent {
  final String newPassword;
  SaveNewPasswordRequested(this.newPassword);
}

/// تسجيل الخروج (UC-02)
class LogoutRequested extends AuthEvent {}
