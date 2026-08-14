import 'dart:typed_data';

import 'package:driver_app_dash/features/owner/data/models/owner_reports_model.dart';

abstract class OwnerReportsState {}

class OwnerReportsInitial extends OwnerReportsState {}

class OwnerReportsLoading extends OwnerReportsState {
  final List<OwnerReportModel> previousReports;

  OwnerReportsLoading({
    this.previousReports = const [],
  });
}

class OwnerReportsLoaded extends OwnerReportsState {
  final List<OwnerReportModel> reports;

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

class OwnerReportsExporting extends OwnerReportsState {
  final List<OwnerReportModel> reports;

  final int? companyId;
  final String? dateFrom;
  final String? dateTo;

  OwnerReportsExporting({
    required this.reports,
    this.companyId,
    this.dateFrom,
    this.dateTo,
  });
}

class OwnerReportsExported extends OwnerReportsState {
  // ✅ هنا التعديل
  final Uint8List bytes;

  final String format;
  final List<OwnerReportModel> reports;

  OwnerReportsExported({
    required this.bytes,
    required this.format,
    required this.reports,
  });
}

class OwnerReportsFailure extends OwnerReportsState {
  final String message;

  final List<OwnerReportModel> previousReports;

  OwnerReportsFailure(
    this.message, {
    this.previousReports = const [],
  });
}