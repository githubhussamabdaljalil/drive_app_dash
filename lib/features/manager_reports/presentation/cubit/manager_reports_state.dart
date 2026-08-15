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

class ManagerReportsExporting extends ManagerReportsState {
  final ManagerReportsModel? reports;
  ManagerReportsExporting({this.reports});
}

class ManagerReportsExported extends ManagerReportsState {
  final Uint8List bytes;
  final ManagerReportsModel? reports;
  ManagerReportsExported({required this.bytes, this.reports});
}
