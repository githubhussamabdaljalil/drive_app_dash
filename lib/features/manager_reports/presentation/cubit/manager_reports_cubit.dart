import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/manager_reports_remote_datasource.dart';
import '../../data/models/manager_reports_model.dart';

part 'manager_reports_state.dart';

class ManagerReportsCubit extends Cubit<ManagerReportsState> {
  final ManagerReportsRemoteDataSource _ds = ManagerReportsRemoteDataSource();

  ManagerReportsCubit() : super(ManagerReportsInitial());

  int? _vehicleId;
  int? _driverId;
  String? _dateFrom;
  String? _dateTo;
  ManagerReportsModel? _currentReports;

  int? get vehicleId => _vehicleId;
  int? get driverId => _driverId;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;

  Future<void> load({int? vehicleId, int? driverId, String? dateFrom, String? dateTo}) async {
    if (isClosed) return;
    _vehicleId = vehicleId ?? _vehicleId;
    _driverId = driverId ?? _driverId;
    _dateFrom = dateFrom ?? _dateFrom;
    _dateTo = dateTo ?? _dateTo;

    emit(ManagerReportsLoading());
    try {
      final reports = await _ds.getReports(
        vehicleId: _vehicleId,
        driverId: _driverId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      _currentReports = reports;
      if (!isClosed) emit(ManagerReportsLoaded(reports));
    } catch (e) {
      if (!isClosed) emit(ManagerReportsError(e.toString()));
    }
  }

  Future<void> clearFilters() async {
    _vehicleId = null;
    _driverId = null;
    _dateFrom = null;
    _dateTo = null;
    await load();
  }

  Future<void> exportReports() async {
    if (isClosed) return;
    emit(ManagerReportsExporting(reports: _currentReports));
    try {
      final response = await _ds.exportReports(
        vehicleId: _vehicleId,
        driverId: _driverId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      if (!isClosed) {
        emit(ManagerReportsExported(bytes: Uint8List.fromList(response.bodyBytes), reports: _currentReports));
        if (_currentReports != null) emit(ManagerReportsLoaded(_currentReports!));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ManagerReportsError(e.toString()));
        if (_currentReports != null) emit(ManagerReportsLoaded(_currentReports!));
      }
    }
  }
}
