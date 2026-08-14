part of 'guest_code_cubit.dart';

abstract class GuestCodeState {}

class GuestCodeInitial extends GuestCodeState {}

class GuestCodeLoading extends GuestCodeState {}

class GuestCodeLoaded extends GuestCodeState {
  final List<GuestCodeModel> codes;
  GuestCodeLoaded(this.codes);
}

class GuestCodeSubmitting extends GuestCodeState {
  final List<GuestCodeModel> codes;
  GuestCodeSubmitting(this.codes);
}

class GuestCodeError extends GuestCodeState {
  final String message;
  final List<GuestCodeModel>? codes;
  GuestCodeError(this.message, [this.codes]);
}
