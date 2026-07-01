part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

/// تسجيل دخول ناجح — isFirstLogin = true → توجيه لتغيير كلمة المرور
class AuthSuccess extends AuthState {
  final bool isFirstLogin;
  AuthSuccess({required this.isFirstLogin});
}

/// كلمة المرور تغيرت → توجيه للهوم
class PasswordChanged extends AuthState {}

/// تم إرسال كود الاستعادة
class ResetCodeSent extends AuthState {}

/// الكود صحيح
class ResetCodeVerified extends AuthState {}

/// تم تغيير كلمة المرور بعد الـ reset
class PasswordReset extends AuthState {}

class AuthLoggedOut extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
