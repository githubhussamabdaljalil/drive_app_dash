part of 'destination_cubit.dart';

abstract class DestinationState {}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationLoaded extends DestinationState {
  final List<DestinationModel> destinations;
  DestinationLoaded(this.destinations);
}

class DestinationSubmitting extends DestinationState {
  final List<DestinationModel> destinations;
  DestinationSubmitting(this.destinations);
}

class DestinationError extends DestinationState {
  final String message;
  final List<DestinationModel>? destinations;
  DestinationError(this.message, [this.destinations]);
}
