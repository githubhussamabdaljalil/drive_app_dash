import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/owner_remote_datasource.dart';
import '../../data/models/owner_statistics_model.dart';

part 'owner_statistics_state.dart';

class OwnerStatisticsCubit extends Cubit<OwnerStatisticsState> {
  // ignore: unused_field
  final OwnerRemoteDataSource _ds = OwnerRemoteDataSource();

  OwnerStatisticsCubit() : super(OwnerStatisticsInitial());

  /// Load statistics
  ///
  /// ⚠️ TEMPORARY: Using hardcoded data until Backend API is ready
  /// Backend API: GET /admin/owner/statistics
  Future<void> load() async {
    if (isClosed) return;
    emit(OwnerStatisticsLoading());

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace with real API call when Backend is ready
      // final statistics = await _ds.getStatistics();

      // TEMPORARY: Hardcoded statistics
      const statistics = OwnerStatisticsModel(
        totalCompanies: 14,
        activeCompanies: 12,
        inactiveCompanies: 2,
        totalDrivers: 143,
        activeDrivers: 128,
        inactiveDrivers: 15,
        onTripDrivers: 45,
        totalVehicles: 87,
        activeVehicles: 74,
        inactiveVehicles: 10,
        maintenanceVehicles: 3,
        monthlyGrowth: MonthlyGrowth(
          companiesCount: 2,
          companiesPercent: 16.67,
          driversCount: 11,
          driversPercent: 8.33,
          vehiclesCount: 5,
          vehiclesPercent: 6.10,
        ),
      );

      if (!isClosed) emit(OwnerStatisticsLoaded(statistics));
    } catch (e) {
      if (!isClosed) emit(OwnerStatisticsError(e.toString()));
    }
  }

  Future<void> refresh() => load();
}
