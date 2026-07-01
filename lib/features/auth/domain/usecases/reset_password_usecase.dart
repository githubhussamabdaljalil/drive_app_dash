import '../repositories/auth_repository.dart';

/// UC-03: إرسال كود الاستعادة — يُرسل لكلا القناتين دائمًا
class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<void> sendCode(String email) => repository.sendResetCode(email);
  Future<void> verifyCode(String code) => repository.verifyResetCode(code);
  Future<void> saveNew(String newPassword) => repository.saveNewPassword(newPassword);
}
