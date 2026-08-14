part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AdminLoginSuccess extends AuthState {
  final String? challengeToken;
  final UserModel? user;
  final String? token;
  AdminLoginSuccess({this.challengeToken, this.user, this.token});
}

class MustChangePassword extends AuthState {}

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
