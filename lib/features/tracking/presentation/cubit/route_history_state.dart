part of 'route_history_cubit.dart';

abstract class RouteHistoryState {}

class RouteHistoryInitial extends RouteHistoryState {}

class RouteHistoryLoading extends RouteHistoryState {}

class RouteHistoryLoaded extends RouteHistoryState {
  final List<RoutePointModel> points;
  RouteHistoryLoaded(this.points);
}

class RouteHistoryError extends RouteHistoryState {
  final String message;
  RouteHistoryError(this.message);
}
