part of 'guest_tracking_cubit.dart';

abstract class GuestTrackingState {}

class GuestTrackingInitial extends GuestTrackingState {}

class GuestTrackingLoading extends GuestTrackingState {}

class GuestTrackingLoaded extends GuestTrackingState {
  final GuestTrackingModel data;
  final RealtimeStatus connection;
  final bool hasNewLocation;

  GuestTrackingLoaded({
    required this.data,
    this.connection = RealtimeStatus.disconnected,
    this.hasNewLocation = false,
  });

  GuestTrackingLoaded copyWith({
    GuestTrackingModel? data,
    RealtimeStatus? connection,
    bool hasNewLocation = false,
  }) {
    return GuestTrackingLoaded(
      data: data ?? this.data,
      connection: connection ?? this.connection,
      hasNewLocation: hasNewLocation,
    );
  }
}

class GuestTrackingError extends GuestTrackingState {
  final String message;
  final bool isExpired;

  GuestTrackingError(this.message, {this.isExpired = false});
}
