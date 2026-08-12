import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/owner_remote_datasource.dart';
import '../../data/models/owner_reports_model.dart';

part 'owner_reports_state.dart';

class OwnerReportsCubit extends Cubit<OwnerReportsState> {
  final OwnerRemoteDataSource _ds = OwnerRemoteDataSource();

  OwnerReportsCubit() : super(OwnerReportsInitial());

  /// Load reports with optional filters
  Future<void> load({int? companyId, String? dateFrom, String? dateTo}) async {
    if (isClosed) return;
    emit(OwnerReportsLoading());
    try {
      final data = await _ds.getReports(
        companyId: companyId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      final reports = OwnerReportsModel.fromJson(data);
      if (!isClosed) {
        emit(
          OwnerReportsLoaded(
            reports: reports,
            companyId: companyId,
            dateFrom: dateFrom,
            dateTo: dateTo,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) emit(OwnerReportsError(e.toString()));
    }
  }

  /// Refresh with current filters
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is OwnerReportsLoaded) {
      await load(
        companyId: currentState.companyId,
        dateFrom: currentState.dateFrom,
        dateTo: currentState.dateTo,
      );
    } else {
      await load();
    }
  }

  /// Export report as PDF or Excel
  ///
  /// Note: File download is not yet implemented in ApiClient
  /// This will throw UnimplementedError
  Future<void> export({
    required String format,
    int? companyId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      await _ds.exportReport(
        format: format,
        companyId: companyId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      if (!isClosed) emit(OwnerReportsError(e.toString()));
    }
  }
}
