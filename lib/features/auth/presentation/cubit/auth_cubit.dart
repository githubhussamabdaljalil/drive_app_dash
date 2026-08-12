import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/storage/local_storage_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _ds = AuthRemoteDataSource();
  final LocalStorageService _store = LocalStorageService.instance;

  AuthCubit() : super(AuthInitial());

  void selectRole(String role) => emit(RoleSelected(role));

  Future<void> adminLogin(String email, String password) async {
    emit(AuthLoading());
    try {
      final data = await _ds.adminLogin(email, password);
      if (data['challenge_token'] != null) {
        emit(AdminLoginSuccess(challengeToken: data['challenge_token']));
        return;
      }
      final token = data['token'] as String;
      final user = UserModel.fromAdminJson(data);
      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);
      if (user.isFirstLogin) {
        emit(MustChangePassword());
      } else {
        emit(AdminLoginSuccess(user: user, token: token));
      }
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> adminVerifyTotp(String challengeToken, String code) async {
    emit(AuthLoading());
    try {
      final data = await _ds.adminVerifyTotp(challengeToken, code);
      final token = data['token'] as String;
      final user = UserModel.fromAdminJson(data);
      await _store.saveToken(token);
      await _store.saveRole(user.role);
      await _store.saveName(user.name);
      if (user.isFirstLogin) {
        emit(MustChangePassword());
      } else {
        emit(AdminLoginSuccess(user: user, token: token));
      }
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> driverLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final data = await _ds.driverLogin(phone, password);
      if (data['requires_otp'] == true) {
        emit(DriverLoginSuccess(requiresOtp: true, phone: phone));
        return;
      }
      final token = data['token'] as String;
      final user = UserModel.fromDriverJson(data);
      await _store.saveToken(token);
      await _store.saveRole(UserRole.driver);
      await _store.saveName(user.name);
      if (user.isFirstLogin) {
        emit(MustChangePassword(isDriver: true));
      } else {
        emit(DriverLoginSuccess(user: user, token: token));
      }
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> driverVerifyOtp(String phone, String code) async {
    emit(AuthLoading());
    try {
      final data = await _ds.driverVerifyOtp(phone, code);
      final token = data['token'] as String;
      final user = UserModel.fromDriverJson(data);
      await _store.saveToken(token);
      await _store.saveRole(UserRole.driver);
      await _store.saveName(user.name);
      emit(DriverLoginSuccess(user: user, token: token));
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> changePassword(String current, String newPass, {bool isDriver = false}) async {
    emit(AuthLoading());
    try {
      if (isDriver) {
        await _ds.driverChangePassword(current, newPass);
      } else {
        await _ds.adminChangePassword(current, newPass);
      }
      emit(PasswordChanged());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _ds.adminForgotPassword(email);
      emit(ResetCodeSent());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> verifyResetCode(String email, String code) async {
    emit(AuthLoading());
    try {
      await _ds.adminVerifyResetCode(email, code);
      emit(ResetCodeVerified(email, code));
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> resetPassword(String email, String code, String newPass) async {
    emit(AuthLoading());
    try {
      await _ds.adminResetPassword(email, code, newPass);
      emit(PasswordReset());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> logout() async {
    final role = _store.getRole();
    try {
      if (role == UserRole.driver) {
        await _ds.driverLogout();
      } else {
        await _ds.adminLogout();
      }
    } catch (_) {}
    await _store.clearAll();
    emit(AuthLoggedOut());
  }
}
