part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class RoleSelected extends AuthState {
  final String role;
  RoleSelected(this.role);
}

class AdminLoginSuccess extends AuthState {
  final String? challengeToken;
  final UserModel? user;
  final String? token;
  AdminLoginSuccess({this.challengeToken, this.user, this.token});
}

class DriverLoginSuccess extends AuthState {
  final bool requiresOtp;
  final String? phone;
  final UserModel? user;
  final String? token;
  DriverLoginSuccess({this.requiresOtp = false, this.phone, this.user, this.token});
}

class MustChangePassword extends AuthState {
  final bool isDriver;
  MustChangePassword({this.isDriver = false});
}

class PasswordChanged extends AuthState {}

class ResetCodeSent extends AuthState {}
class ResetCodeVerified extends AuthState {
  final String email;
  final String code;
  ResetCodeVerified(this.email, this.code);
}
class PasswordReset extends AuthState {}

class AuthLoggedOut extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
