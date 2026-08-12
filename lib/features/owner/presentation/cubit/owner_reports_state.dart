part of 'owner_reports_cubit.dart';

abstract class OwnerReportsState {}

class OwnerReportsInitial extends OwnerReportsState {}

class OwnerReportsLoading extends OwnerReportsState {}

class OwnerReportsLoaded extends OwnerReportsState {
  final OwnerReportsModel reports;
  final int? companyId;
  final String? dateFrom;
  final String? dateTo;

  OwnerReportsLoaded({
    required this.reports,
    this.companyId,
    this.dateFrom,
    this.dateTo,
  });
}

class OwnerReportsError extends OwnerReportsState {
  final String message;
  OwnerReportsError(this.message);
}
