part of 'vehicle_cubit.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;
  VehicleLoaded(this.vehicles);
}

class VehicleSubmitting extends VehicleState {
  final List<VehicleModel> vehicles;
  VehicleSubmitting(this.vehicles);
}

class VehicleError extends VehicleState {
  final String message;
  final List<VehicleModel>? vehicles;
  VehicleError(this.message, [this.vehicles]);
}
