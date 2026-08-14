/// Manager Reports Model
/// Company-scoped aggregated report — GET /admin/manager/reports
///
/// Per the API docs: "One aggregated row: vehicles_count,
/// active_vehicles_count, managers_count, drivers_count, attendance_count,
/// guest_codes_issued_count + sos/destinations broken down by status."
class ManagerReportsModel {
  final int vehiclesCount;
  final int activeVehiclesCount;
  final int managersCount;
  final int driversCount;
  final int attendanceCount;
  final int guestCodesIssuedCount;
  final ReportStatusBreakdown sos;
  final ReportStatusBreakdown destinations;

  const ManagerReportsModel({
    required this.vehiclesCount,
    required this.activeVehiclesCount,
    required this.managersCount,
    required this.driversCount,
    required this.attendanceCount,
    required this.guestCodesIssuedCount,
    required this.sos,
    required this.destinations,
  });

  factory ManagerReportsModel.empty() => ManagerReportsModel(
        vehiclesCount: 0,
        activeVehiclesCount: 0,
        managersCount: 0,
        driversCount: 0,
        attendanceCount: 0,
        guestCodesIssuedCount: 0,
        sos: ReportStatusBreakdown.empty(),
        destinations: ReportStatusBreakdown.empty(),
      );

  factory ManagerReportsModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    return ManagerReportsModel(
      vehiclesCount: asInt(json['vehicles_count']),
      activeVehiclesCount: asInt(json['active_vehicles_count']),
      managersCount: asInt(json['managers_count']),
      driversCount: asInt(json['drivers_count']),
      attendanceCount: asInt(json['attendance_count']),
      guestCodesIssuedCount: asInt(json['guest_codes_issued_count']),
      sos: ReportStatusBreakdown.fromJson(json['sos'] ?? {}),
      destinations: ReportStatusBreakdown.fromJson(json['destinations'] ?? {}),
    );
  }
}

/// A "total + by_status" breakdown, shared shape between sos & destinations.
class ReportStatusBreakdown {
  final int total;
  final Map<String, int> byStatus;

  const ReportStatusBreakdown({required this.total, required this.byStatus});

  factory ReportStatusBreakdown.empty() => const ReportStatusBreakdown(total: 0, byStatus: {});

  factory ReportStatusBreakdown.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    final rawByStatus = json['by_status'];
    final byStatus = <String, int>{};
    if (rawByStatus is Map) {
      for (final entry in rawByStatus.entries) {
        byStatus[entry.key.toString()] = asInt(entry.value);
      }
    }
    return ReportStatusBreakdown(total: asInt(json['total']), byStatus: byStatus);
  }
}
