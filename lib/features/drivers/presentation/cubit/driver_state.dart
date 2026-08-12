part of 'driver_cubit.dart';

abstract class DriverState {}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final List<DriverModel> drivers;
  DriverLoaded(this.drivers);
}

class DriverSubmitting extends DriverState {
  final List<DriverModel> drivers;
  DriverSubmitting(this.drivers);
}

class DriverError extends DriverState {
  final String message;
  final List<DriverModel>? drivers;
  DriverError(this.message, [this.drivers]);
}
