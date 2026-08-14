part of 'qr_code_cubit.dart';

abstract class QrCodeState {}

class QrCodeInitial extends QrCodeState {}

class QrCodeLoading extends QrCodeState {}

// `code` is null when the vehicle has no active code yet.
class QrCodeLoaded extends QrCodeState {
  final QrCodeModel? code;
  QrCodeLoaded(this.code);
}

class QrCodeSubmitting extends QrCodeState {
  final QrCodeModel? code;
  QrCodeSubmitting(this.code);
}

class QrCodeError extends QrCodeState {
  final String message;
  final QrCodeModel? code;
  QrCodeError(this.message, [this.code]);
}
