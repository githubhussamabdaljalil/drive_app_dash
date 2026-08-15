import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/storage/local_storage_service.dart';

part 'auth_state.dart';

/// Authentication Cubit.
///
/// The backend determines the user's role.
/// Supported roles:
/// - owner
/// - manager
class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _ds = AuthRemoteDataSource();

  final LocalStorageService _store =
      LocalStorageService.instance;

  AuthCubit() : super(AuthInitial());

  // ================================================================
  // LOGIN
  // ================================================================

  Future<void> adminLogin(
    String email,
    String password,
  ) async {
    emit(AuthLoading());

    try {
      final data = await _ds.adminLogin(
        email,
        password,
      );

      final stage = data['stage'];

      // ============================================================
      // FIRST TIME TOTP SETUP
      // ============================================================

      if (stage == 'totp_setup_required') {
        emit(
          AdminTotpSetupRequired(
            challengeToken: data['challenge_token'] as String,
            secret: data['secret'] as String,
            provisioningUri:
                data['provisioning_uri'] as String,
          ),
        );

        return;
      }

      // ============================================================
      // TOTP ALREADY CONFIGURED
      // ============================================================

      if (stage == 'totp_required') {
        emit(
          AdminTotpRequired(
            challengeToken:
                data['challenge_token'] as String,
          ),
        );

        return;
      }

      // ============================================================
      // NORMAL LOGIN
      // ============================================================

      final token = data['token'] as String;

      final user = UserModel.fromAdminJson(data);

      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);

      // ============================================================
      // FIRST LOGIN
      // ============================================================

      if (user.isFirstLogin) {
        emit(MustChangePassword());
        return;
      }

      // ============================================================
      // SUCCESS
      // ============================================================

      emit(
        AdminLoginSuccess(
          user: user,
          token: token,
        ),
      );
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // VERIFY TOTP
  // ================================================================

  Future<void> adminVerifyTotp(
    String challengeToken,
    String code,
  ) async {
    emit(AuthLoading());

    try {
      final data = await _ds.adminVerifyTotp(
        challengeToken,
        code,
      );

      final token = data['token'] as String;

      final user = UserModel.fromAdminJson(data);

      // Backend determines the role:
      // owner / manager

      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);

      if (user.isFirstLogin) {
        emit(MustChangePassword());
        return;
      }

      emit(
        AdminLoginSuccess(
          user: user,
          token: token,
        ),
      );
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // CHANGE PASSWORD
  // ================================================================

  Future<void> changePassword(
    String current,
    String newPass,
  ) async {
    emit(AuthLoading());

    try {
      await _ds.adminChangePassword(
        current,
        newPass,
      );

      emit(PasswordChanged());
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // FORGOT PASSWORD
  // ================================================================

  Future<void> forgotPassword(
    String email,
  ) async {
    emit(AuthLoading());

    try {
      await _ds.adminForgotPassword(email);

      emit(ResetCodeSent());
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // VERIFY RESET CODE
  // ================================================================

  Future<void> verifyResetCode(
    String email,
    String code,
  ) async {
    emit(AuthLoading());

    try {
      await _ds.adminVerifyResetCode(
        email,
        code,
      );

      emit(
        ResetCodeVerified(
          email,
          code,
        ),
      );
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // RESET PASSWORD
  // ================================================================

  Future<void> resetPassword(
    String email,
    String code,
    String newPass,
  ) async {
    emit(AuthLoading());

    try {
      await _ds.adminResetPassword(
        email,
        code,
        newPass,
      );

      emit(PasswordReset());
    } catch (err) {
      emit(
        AuthFailure(
          err.toString(),
        ),
      );
    }
  }

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> logout() async {
    try {
      await _ds.adminLogout();
    } catch (_) {}

    await _store.clearAll();
  }
}