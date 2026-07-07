part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SelectRoleEvent extends AuthEvent {
  final String role; // 'owner' | 'manager' | 'driver'
  SelectRoleEvent(this.role);
}

class AdminLoginEvent extends AuthEvent {
  final String email;
  final String password;
  AdminLoginEvent(this.email, this.password);
}

class AdminVerifyTotpEvent extends AuthEvent {
  final String challengeToken;
  final String code;
  AdminVerifyTotpEvent(this.challengeToken, this.code);
}

class DriverLoginEvent extends AuthEvent {
  final String phone;
  final String password;
  DriverLoginEvent(this.phone, this.password);
}

class DriverVerifyOtpEvent extends AuthEvent {
  final String phone;
  final String code;
  DriverVerifyOtpEvent(this.phone, this.code);
}

class ChangePasswordEvent extends AuthEvent {
  final String current;
  final String newPass;
  final bool isDriver;
  ChangePasswordEvent(this.current, this.newPass, {this.isDriver = false});
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  ForgotPasswordEvent(this.email);
}

class VerifyResetCodeEvent extends AuthEvent {
  final String email;
  final String code;
  VerifyResetCodeEvent(this.email, this.code);
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String code;
  final String newPass;
  ResetPasswordEvent(this.email, this.code, this.newPass);
}

class LogoutEvent extends AuthEvent {}
