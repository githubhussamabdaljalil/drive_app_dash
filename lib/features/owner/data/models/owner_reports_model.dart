class OwnerReportModel {
  final int companyId;
  final String companyName;
  final String companyStatus;

  final int vehiclesCount;
  final int activeVehiclesCount;
  final int managersCount;
  final int driversCount;
  final int attendanceCount;
  final int guestCodesIssuedCount;

  final SosReportModel sos;
  final DestinationReportModel destinations;

  const OwnerReportModel({
    required this.companyId,
    required this.companyName,
    required this.companyStatus,
    required this.vehiclesCount,
    required this.activeVehiclesCount,
    required this.managersCount,
    required this.driversCount,
    required this.attendanceCount,
    required this.guestCodesIssuedCount,
    required this.sos,
    required this.destinations,
  });

  factory OwnerReportModel.fromJson(Map<String, dynamic> json) {
    return OwnerReportModel(
      companyId: json['company_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      companyStatus: json['company_status'] ?? '',

      vehiclesCount: json['vehicles_count'] ?? 0,
      activeVehiclesCount: json['active_vehicles_count'] ?? 0,
      managersCount: json['managers_count'] ?? 0,
      driversCount: json['drivers_count'] ?? 0,
      attendanceCount: json['attendance_count'] ?? 0,
      guestCodesIssuedCount:
          json['guest_codes_issued_count'] ?? 0,

      sos: SosReportModel.fromJson(
        Map<String, dynamic>.from(
          json['sos'] ?? {},
        ),
      ),

      destinations: DestinationReportModel.fromJson(
        Map<String, dynamic>.from(
          json['destinations'] ?? {},
        ),
      ),
    );
  }
}

// ===========================================================================
// SOS
// ===========================================================================

class SosReportModel {
  final int total;
  final int active;
  final int acknowledged;
  final int resolved;

  const SosReportModel({
    required this.total,
    required this.active,
    required this.acknowledged,
    required this.resolved,
  });

  factory SosReportModel.fromJson(Map<String, dynamic> json) {
    return SosReportModel(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      acknowledged: json['acknowledged'] ?? 0,
      resolved: json['resolved'] ?? 0,
    );
  }
}

// ===========================================================================
// DESTINATIONS
// ===========================================================================

class DestinationReportModel {
  final int total;
  final int sent;
  final int accepted;
  final int rejected;
  final int cancelled;

  const DestinationReportModel({
    required this.total,
    required this.sent,
    required this.accepted,
    required this.rejected,
    required this.cancelled,
  });

  factory DestinationReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DestinationReportModel(
      total: json['total'] ?? 0,
      sent: json['sent'] ?? 0,
      accepted: json['accepted'] ?? 0,
      rejected: json['rejected'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}