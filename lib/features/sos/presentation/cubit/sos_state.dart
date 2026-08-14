part of 'sos_cubit.dart';

abstract class SosState {}

class SosInitial extends SosState {}

class SosLoading extends SosState {}

class SosLoaded extends SosState {
  final List<SosEventModel> events;
  SosLoaded(this.events);
}

class SosSubmitting extends SosState {
  final List<SosEventModel> events;
  SosSubmitting(this.events);
}

class SosError extends SosState {
  final String message;
  final List<SosEventModel>? events;
  SosError(this.message, [this.events]);
}
