import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc — يدير كل حالات المصادقة حسب SRS
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<ChangePasswordRequested>(_onChangePassword);
    on<ResetPasswordRequested>(_onResetPassword);
    on<VerifyResetCodeRequested>(_onVerifyCode);
    on<SaveNewPasswordRequested>(_onSaveNewPassword);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: authRepository.login(e.email, e.password)
      await Future.delayed(const Duration(seconds: 1));
      // إذا كانت كلمة المرور مؤقتة → isFirstLogin = true
      emit(AuthSuccess(isFirstLogin: true));
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onChangePassword(ChangePasswordRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: authRepository.changePassword(e.tempPassword, e.newPassword)
      await Future.delayed(const Duration(seconds: 1));
      emit(PasswordChanged());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPasswordRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: authRepository.sendResetCode(e.email)
      // حسب UC-03: الكود يُرسل لكلا القناتين دائمًا
      await Future.delayed(const Duration(seconds: 1));
      emit(ResetCodeSent());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onVerifyCode(VerifyResetCodeRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: authRepository.verifyResetCode(e.code)
      await Future.delayed(const Duration(milliseconds: 800));
      emit(ResetCodeVerified());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onSaveNewPassword(SaveNewPasswordRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: authRepository.saveNewPassword(e.newPassword)
      await Future.delayed(const Duration(milliseconds: 800));
      emit(PasswordReset());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    // TODO: authRepository.logout()
    emit(AuthLoggedOut());
  }
}
