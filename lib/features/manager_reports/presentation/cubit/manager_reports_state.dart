part of 'manager_reports_cubit.dart';

abstract class ManagerReportsState {}

class ManagerReportsInitial extends ManagerReportsState {}

class ManagerReportsLoading extends ManagerReportsState {}

class ManagerReportsLoaded extends ManagerReportsState {
  final ManagerReportsModel reports;
  ManagerReportsLoaded(this.reports);
}

class ManagerReportsError extends ManagerReportsState {
  final String message;
  ManagerReportsError(this.message);
}
