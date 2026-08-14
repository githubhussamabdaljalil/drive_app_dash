import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/owner_remote_datasource.dart';
import '../../data/models/owner_reports_model.dart';
import 'owner_reports_state.dart';

class OwnerReportsCubit extends Cubit<OwnerReportsState> {
  final OwnerReportsRemoteDataSource _ds =
      OwnerReportsRemoteDataSource();

  OwnerReportsCubit()
      : super(OwnerReportsInitial());

  // ===========================================================================
  // CURRENT FILTERS
  // ===========================================================================

  int? companyId;
  String? dateFrom;
  String? dateTo;

  // ===========================================================================
  // CURRENT REPORTS
  // ===========================================================================

  List<OwnerReportModel> _currentReports = [];

  List<OwnerReportModel> get currentReports =>
      List.unmodifiable(_currentReports);

  // ===========================================================================
  // LOAD REPORTS
  // ===========================================================================

  Future<void> loadReports({
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    this.companyId = companyId;
    this.dateFrom = dateFrom;
    this.dateTo = dateTo;

    emit(
      OwnerReportsLoading(
        previousReports: _currentReports,
      ),
    );

    try {
      final reports = await _ds.getReports(
        companyId: companyId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      _currentReports = reports;

      emit(
        OwnerReportsLoaded(
          reports: reports,
          companyId: companyId,
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      );
    } catch (e) {
      emit(
        OwnerReportsFailure(
          e.toString(),
          previousReports: _currentReports,
        ),
      );
    }
  }

  // ===========================================================================
  // EXPORT
  // ===========================================================================

  Future<void> exportReports({
    required String format,
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    // إذا لم يتم إرسال الفلاتر، استخدم الفلاتر الحالية
    final selectedCompanyId = companyId ?? this.companyId;
    final selectedDateFrom = dateFrom ?? this.dateFrom;
    final selectedDateTo = dateTo ?? this.dateTo;

    emit(
      OwnerReportsExporting(
        reports: _currentReports,
        companyId: selectedCompanyId,
        dateFrom: selectedDateFrom,
        dateTo: selectedDateTo,
      ),
    );

    try {
      final response = await _ds.exportReports(
        format: format,
        companyId: selectedCompanyId,
        dateFrom: selectedDateFrom,
        dateTo: selectedDateTo,
      );

      emit(
        OwnerReportsExported(
          bytes: Uint8List.fromList(response.bodyBytes),
          format: format,
          reports: _currentReports,
        ),
      );

      // نرجع للحالة Loaded بعد التصدير حتى تبقى الصفحة طبيعية
      emit(
        OwnerReportsLoaded(
          reports: _currentReports,
          companyId: selectedCompanyId,
          dateFrom: selectedDateFrom,
          dateTo: selectedDateTo,
        ),
      );
    } catch (e) {
      emit(
        OwnerReportsFailure(
          e.toString(),
          previousReports: _currentReports,
        ),
      );

      // إذا كانت لدينا بيانات، نرجعها مباشرة
      if (_currentReports.isNotEmpty) {
        emit(
          OwnerReportsLoaded(
            reports: _currentReports,
            companyId: selectedCompanyId,
            dateFrom: selectedDateFrom,
            dateTo: selectedDateTo,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // CLEAR FILTERS
  // ===========================================================================

  Future<void> clearFilters() async {
    companyId = null;
    dateFrom = null;
    dateTo = null;

    await loadReports();
  }
}