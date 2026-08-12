/// Owner Reports Model
/// Represents platform-wide reports data
///
/// Backend API: GET /admin/owner/reports
class OwnerReportsModel {
  final CompaniesReportData companies;
  final UsersReportData users;
  final VehiclesReportData vehicles;
  final AttendanceReportData attendance;
  final SosReportData sos;
  final DestinationsReportData destinations;

  const OwnerReportsModel({
    required this.companies,
    required this.users,
    required this.vehicles,
    required this.attendance,
    required this.sos,
    required this.destinations,
  });

  factory OwnerReportsModel.fromJson(Map<String, dynamic> json) {
    return OwnerReportsModel(
      companies: CompaniesReportData.fromJson(json['companies'] ?? {}),
      users: UsersReportData.fromJson(json['users'] ?? {}),
      vehicles: VehiclesReportData.fromJson(json['vehicles'] ?? {}),
      attendance: AttendanceReportData.fromJson(json['attendance'] ?? {}),
      sos: SosReportData.fromJson(json['sos'] ?? {}),
      destinations: DestinationsReportData.fromJson(json['destinations'] ?? {}),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Companies Report Data
// ══════════════════════════════════════════════════════════════════════════

class CompaniesReportData {
  final int total;
  final int active;
  final int disabled;

  const CompaniesReportData({
    required this.total,
    required this.active,
    required this.disabled,
  });

  factory CompaniesReportData.fromJson(Map<String, dynamic> json) {
    return CompaniesReportData(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      disabled: json['disabled'] ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Users Report Data
// ══════════════════════════════════════════════════════════════════════════

class UsersReportData {
  final int total;
  final int managers;
  final int subManagers;
  final int drivers;

  const UsersReportData({
    required this.total,
    required this.managers,
    required this.subManagers,
    required this.drivers,
  });

  factory UsersReportData.fromJson(Map<String, dynamic> json) {
    return UsersReportData(
      total: json['total'] ?? 0,
      managers: json['managers'] ?? 0,
      subManagers: json['sub_managers'] ?? 0,
      drivers: json['drivers'] ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Vehicles Report Data
// ══════════════════════════════════════════════════════════════════════════

class VehiclesReportData {
  final int total;
  final int active;
  final int inactive;
  final int maintenance;

  const VehiclesReportData({
    required this.total,
    required this.active,
    required this.inactive,
    required this.maintenance,
  });

  factory VehiclesReportData.fromJson(Map<String, dynamic> json) {
    return VehiclesReportData(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      maintenance: json['maintenance'] ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Attendance Report Data
// ══════════════════════════════════════════════════════════════════════════

class AttendanceReportData {
  final int total;
  final int checkIn;
  final int checkOut;

  const AttendanceReportData({
    required this.total,
    required this.checkIn,
    required this.checkOut,
  });

  factory AttendanceReportData.fromJson(Map<String, dynamic> json) {
    return AttendanceReportData(
      total: json['total'] ?? 0,
      checkIn: json['check_in'] ?? 0,
      checkOut: json['check_out'] ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SOS Report Data
// ══════════════════════════════════════════════════════════════════════════

class SosReportData {
  final int total;
  final StatusBreakdown byStatus;

  const SosReportData({required this.total, required this.byStatus});

  factory SosReportData.fromJson(Map<String, dynamic> json) {
    return SosReportData(
      total: json['total'] ?? 0,
      byStatus: StatusBreakdown.fromJson(json['by_status'] ?? {}),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Destinations Report Data
// ══════════════════════════════════════════════════════════════════════════

class DestinationsReportData {
  final int total;
  final StatusBreakdown byStatus;

  const DestinationsReportData({required this.total, required this.byStatus});

  factory DestinationsReportData.fromJson(Map<String, dynamic> json) {
    return DestinationsReportData(
      total: json['total'] ?? 0,
      byStatus: StatusBreakdown.fromJson(json['by_status'] ?? {}),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Status Breakdown (Shared)
// ══════════════════════════════════════════════════════════════════════════

class StatusBreakdown {
  final int pending;
  final int inProgress;
  final int completed;
  final int cancelled;

  const StatusBreakdown({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      pending: json['pending'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}
