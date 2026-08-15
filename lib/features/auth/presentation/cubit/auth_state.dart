part of 'auth_cubit.dart';

// ===================================================================
// BASE
// ===================================================================

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// ===================================================================
// TOTP SETUP
// ===================================================================

/// First-time TOTP setup.
///
/// Backend:
///
/// stage = totp_setup_required
///
/// Returns:
/// - challenge_token
/// - secret
/// - provisioning_uri
class AdminTotpSetupRequired extends AuthState {
  final String challengeToken;
  final String secret;
  final String provisioningUri;

  AdminTotpSetupRequired({
    required this.challengeToken,
    required this.secret,
    required this.provisioningUri,
  });
}

// ===================================================================
// TOTP REQUIRED
// ===================================================================

/// TOTP has already been configured.
///
/// Backend:
///
/// stage = totp_required
class AdminTotpRequired extends AuthState {
  final String challengeToken;

  AdminTotpRequired({
    required this.challengeToken,
  });
}

// ===================================================================
// LOGIN SUCCESS
// ===================================================================

class AdminLoginSuccess extends AuthState {
  final String? challengeToken;
  final UserModel? user;
  final String? token;

  AdminLoginSuccess({
    this.challengeToken,
    this.user,
    this.token,
  });
}

// ===================================================================
// PASSWORD
// ===================================================================

class MustChangePassword extends AuthState {}

class PasswordChanged extends AuthState {}

// ===================================================================
// FORGOT PASSWORD
// ===================================================================

class ResetCodeSent extends AuthState {}

class ResetCodeVerified extends AuthState {
  final String email;
  final String code;

  ResetCodeVerified(
    this.email,
    this.code,
  );
}

class PasswordReset extends AuthState {}

// ===================================================================
// LOGOUT
// ===================================================================

class AuthLoggedOut extends AuthState {}

// ===================================================================
// ERROR
// ===================================================================

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}