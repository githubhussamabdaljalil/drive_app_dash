import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/storage/local_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _ds = AuthRemoteDataSource();
  final LocalStorageService  _store = LocalStorageService.instance;

  AuthBloc() : super(AuthInitial()) {
    on<SelectRoleEvent>   (_onSelectRole);
    on<AdminLoginEvent>   (_onAdminLogin);
    on<AdminVerifyTotpEvent>(_onVerifyTotp);
    on<DriverLoginEvent>  (_onDriverLogin);
    on<DriverVerifyOtpEvent>(_onVerifyOtp);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ForgotPasswordEvent>(_onForgot);
    on<VerifyResetCodeEvent>(_onVerifyReset);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>       (_onLogout);
  }

  void _onSelectRole(SelectRoleEvent e, Emitter<AuthState> emit) =>
      emit(RoleSelected(e.role));

  Future<void> _onAdminLogin(AdminLoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data = await _ds.adminLogin(e.email, e.password);
      // If TOTP required
      if (data['challenge_token'] != null) {
        emit(AdminLoginSuccess(challengeToken: data['challenge_token']));
        return;
      }
      final token = data['token'] as String;
      final user  = UserModel.fromAdminJson(data);
      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);
      if (user.isFirstLogin) {
        emit(MustChangePassword());
      } else {
        emit(AdminLoginSuccess(user: user, token: token));
      }
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onVerifyTotp(AdminVerifyTotpEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data  = await _ds.adminVerifyTotp(e.challengeToken, e.code);
      final token = data['token'] as String;
      final user  = UserModel.fromAdminJson(data);
      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);
      emit(AdminLoginSuccess(user: user, token: token));
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onDriverLogin(DriverLoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data = await _ds.driverLogin(e.phone, e.password);
      if (data['requires_otp'] == true) {
        emit(DriverLoginSuccess(requiresOtp: true, phone: e.phone));
        return;
      }
      final token = data['token'] as String;
      final user  = UserModel.fromDriverJson(data);
      await _store.saveToken(token);
      await _store.saveRole(UserRole.driver);
      await _store.saveName(user.name);
      if (user.isFirstLogin) {
        emit(MustChangePassword(isDriver: true));
      } else {
        emit(DriverLoginSuccess(user: user, token: token));
      }
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onVerifyOtp(DriverVerifyOtpEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data  = await _ds.driverVerifyOtp(e.phone, e.code);
      final token = data['token'] as String;
      final user  = UserModel.fromDriverJson(data);
      await _store.saveToken(token);
      await _store.saveRole(UserRole.driver);
      await _store.saveName(user.name);
      emit(DriverLoginSuccess(user: user, token: token));
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onChangePassword(ChangePasswordEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (e.isDriver) {
        await _ds.driverChangePassword(e.current, e.newPass);
      } else {
        await _ds.adminChangePassword(e.current, e.newPass);
      }
      emit(PasswordChanged());
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onForgot(ForgotPasswordEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _ds.adminForgotPassword(e.email);
      emit(ResetCodeSent());
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onVerifyReset(VerifyResetCodeEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _ds.adminVerifyResetCode(e.email, e.code);
      emit(ResetCodeVerified(e.email, e.code));
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onResetPassword(ResetPasswordEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _ds.adminResetPassword(e.email, e.code, e.newPass);
      emit(PasswordReset());
    } catch (err) { emit(AuthFailure(err.toString())); }
  }

  Future<void> _onLogout(LogoutEvent e, Emitter<AuthState> emit) async {
    final role = _store.getRole();
    try {
      if (role == UserRole.driver) await _ds.driverLogout();
      else await _ds.adminLogout();
    } catch (_) {}
    await _store.clearAll();
    emit(AuthLoggedOut());
  }
}
