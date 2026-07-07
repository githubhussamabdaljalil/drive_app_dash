part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

/// Role selected — show correct login form
class RoleSelected extends AuthState {
  final String role;
  RoleSelected(this.role);
}

/// Admin logged in — may need TOTP step 2
class AdminLoginSuccess extends AuthState {
  final String? challengeToken; // non-null → need TOTP
  final UserModel? user;        // non-null → fully logged in
  final String? token;
  AdminLoginSuccess({this.challengeToken, this.user, this.token});
}

/// Driver logged in — may need OTP step 2
class DriverLoginSuccess extends AuthState {
  final bool requiresOtp;
  final String? phone;
  final UserModel? user;
  final String? token;
  DriverLoginSuccess({this.requiresOtp = false, this.phone, this.user, this.token});
}

/// Must change password before proceeding
class MustChangePassword extends AuthState {
  final bool isDriver;
  MustChangePassword({this.isDriver = false});
}

/// Password changed → go home
class PasswordChanged extends AuthState {}

/// Forgot password steps
class ResetCodeSent extends AuthState {}
class ResetCodeVerified extends AuthState { final String email; final String code;
  ResetCodeVerified(this.email, this.code); }
class PasswordReset extends AuthState {}

class AuthLoggedOut extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
