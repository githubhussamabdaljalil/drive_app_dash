import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<void> call(String tempPassword, String newPassword) =>
      repository.changePassword(tempPassword, newPassword);
}
