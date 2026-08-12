class OwnerStatisticsModel {
  final int totalCompanies;
  final int activeCompanies;
  final int inactiveCompanies;
  final int totalDrivers;
  final int activeDrivers;
  final int inactiveDrivers;
  final int onTripDrivers;
  final int totalVehicles;
  final int activeVehicles;
  final int inactiveVehicles;
  final int maintenanceVehicles;
  final MonthlyGrowth? monthlyGrowth;

  const OwnerStatisticsModel({
    required this.totalCompanies,
    required this.activeCompanies,
    required this.inactiveCompanies,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.inactiveDrivers,
    required this.onTripDrivers,
    required this.totalVehicles,
    required this.activeVehicles,
    required this.inactiveVehicles,
    required this.maintenanceVehicles,
    this.monthlyGrowth,
  });

  factory OwnerStatisticsModel.fromJson(Map<String, dynamic> json) {
    return OwnerStatisticsModel(
      totalCompanies: json['total_companies'] ?? 0,
      activeCompanies: json['active_companies'] ?? 0,
      inactiveCompanies: json['inactive_companies'] ?? 0,
      totalDrivers: json['total_drivers'] ?? 0,
      activeDrivers: json['active_drivers'] ?? 0,
      inactiveDrivers: json['inactive_drivers'] ?? 0,
      onTripDrivers: json['on_trip_drivers'] ?? 0,
      totalVehicles: json['total_vehicles'] ?? 0,
      activeVehicles: json['active_vehicles'] ?? 0,
      inactiveVehicles: json['inactive_vehicles'] ?? 0,
      maintenanceVehicles: json['maintenance_vehicles'] ?? 0,
      monthlyGrowth: json['monthly_growth'] != null
          ? MonthlyGrowth.fromJson(json['monthly_growth'])
          : null,
    );
  }

  // Getters for percentages
  double get companiesGrowthPercent => monthlyGrowth?.companiesPercent ?? 0;
  double get driversGrowthPercent => monthlyGrowth?.driversPercent ?? 0;
  double get vehiclesGrowthPercent => monthlyGrowth?.vehiclesPercent ?? 0;

  int get companiesGrowthCount => monthlyGrowth?.companiesCount ?? 0;
  int get driversGrowthCount => monthlyGrowth?.driversCount ?? 0;
  int get vehiclesGrowthCount => monthlyGrowth?.vehiclesCount ?? 0;
}

class MonthlyGrowth {
  final int companiesCount;
  final double companiesPercent;
  final int driversCount;
  final double driversPercent;
  final int vehiclesCount;
  final double vehiclesPercent;

  const MonthlyGrowth({
    required this.companiesCount,
    required this.companiesPercent,
    required this.driversCount,
    required this.driversPercent,
    required this.vehiclesCount,
    required this.vehiclesPercent,
  });

  factory MonthlyGrowth.fromJson(Map<String, dynamic> json) {
    return MonthlyGrowth(
      companiesCount: json['companies_count'] ?? 0,
      companiesPercent: (json['companies_percent'] ?? 0).toDouble(),
      driversCount: json['drivers_count'] ?? 0,
      driversPercent: (json['drivers_percent'] ?? 0).toDouble(),
      vehiclesCount: json['vehicles_count'] ?? 0,
      vehiclesPercent: (json['vehicles_percent'] ?? 0).toDouble(),
    );
  }
}
