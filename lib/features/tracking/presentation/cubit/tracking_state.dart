part of 'tracking_cubit.dart';

abstract class TrackingState {}

class TrackingInitial extends TrackingState {}

/// Resolving the company id from /admin/auth/me, before the socket opens.
class TrackingLoading extends TrackingState {}

class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}

class TrackingReady extends TrackingState {
  final RealtimeStatus connection;
  final Map<int, VehicleLocationModel> locations; // vehicleId -> last known point
  final List<LiveSosAlertModel> activeAlerts; // most recent first, session-only

  TrackingReady({
    required this.connection,
    required this.locations,
    required this.activeAlerts,
  });
}
