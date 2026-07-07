import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final data = await remoteDataSource.adminLogin(email, password);

    final user = UserModel.fromAdminJson(data);

    return UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      isFirstLogin: user.isFirstLogin,
      linkedVehicleId: user.vehiclePlate,
    );
  }

  @override
  Future<void> changePassword(String tempPassword, String newPassword) async {
    await remoteDataSource.adminChangePassword(tempPassword, newPassword);
  }

  @override
  Future<void> sendResetCode(String email) async {
    await remoteDataSource.adminForgotPassword(email);
  }

  @override
  Future<void> verifyResetCode(String code) async {
    throw UnimplementedError('adminVerifyResetCode requires email and code.');
  }

  @override
  Future<void> saveNewPassword(String newPassword) async {
    throw UnimplementedError(
      'adminResetPassword requires email, code and newPassword.',
    );
  }

  @override
  Future<void> updateProfile(String name) async {
    throw UnimplementedError('Update profile API is not implemented.');
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.adminLogout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final data = await remoteDataSource.adminMe();

    final user = UserModel.fromAdminJson(data);

    return UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      isFirstLogin: user.isFirstLogin,
      linkedVehicleId: user.vehiclePlate,
    );
  }
}
