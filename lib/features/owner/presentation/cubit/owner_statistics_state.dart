part of 'owner_statistics_cubit.dart';

abstract class OwnerStatisticsState {}

class OwnerStatisticsInitial extends OwnerStatisticsState {}

class OwnerStatisticsLoading extends OwnerStatisticsState {}

class OwnerStatisticsLoaded extends OwnerStatisticsState {
  final OwnerStatisticsModel statistics;
  OwnerStatisticsLoaded(this.statistics);
}

class OwnerStatisticsError extends OwnerStatisticsState {
  final String message;
  OwnerStatisticsError(this.message);
}
