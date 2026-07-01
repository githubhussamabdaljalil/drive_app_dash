import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) =>
      remoteDataSource.login(email, password);

  @override
  Future<void> changePassword(String tempPassword, String newPassword) =>
      remoteDataSource.changePassword(tempPassword, newPassword);

  @override
  Future<void> sendResetCode(String email) =>
      remoteDataSource.sendResetCode(email);

  @override
  Future<void> verifyResetCode(String code) =>
      remoteDataSource.verifyResetCode(code);

  @override
  Future<void> saveNewPassword(String newPassword) =>
      remoteDataSource.saveNewPassword(newPassword);

  @override
  Future<void> updateProfile(String name) =>
      remoteDataSource.updateProfile(name);

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Future<UserEntity?> getCurrentUser() => remoteDataSource.getCurrentUser();
}
