class SosEventModel {
  final int id;
  final int? driverId;
  final String? driverName;
  final int? vehicleId;
  final String? vehiclePlate;
  final double lat;
  final double lng;
  final String status; // active | acknowledged | resolved — confirm exact enum via /meta/statuses
  final bool isReAlert;
  final String? triggeredAt;
  final String? acknowledgedAt;
  final String? resolvedAt;

  const SosEventModel({
    required this.id,
    this.driverId,
    this.driverName,
    this.vehicleId,
    this.vehiclePlate,
    required this.lat,
    required this.lng,
    required this.status,
    required this.isReAlert,
    this.triggeredAt,
    this.acknowledgedAt,
    this.resolvedAt,
  });

  bool get isActive => status == 'active';
  bool get isAcknowledged => status == 'acknowledged';
  bool get isResolved => status == 'resolved';

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory SosEventModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final vehicle = json['vehicle'];
    return SosEventModel(
      id: json['id'] ?? 0,
      driverId: (json['driver_id'] as num?)?.toInt(),
      driverName: driver is Map ? driver['name']?.toString() : json['driver_name']?.toString(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      vehiclePlate: vehicle is Map ? vehicle['plate_no']?.toString() : json['vehicle_plate']?.toString(),
      lat: _num(json['lat']),
      lng: _num(json['lng']),
      status: json['status']?.toString() ?? 'active',
      isReAlert: json['is_re_alert'] == true,
      // REST always returns triggered_at as null (FRONTEND_QUICKSTART §7)
      // — only the socket payload carries the real value. Parsed here
      // defensively in case a future API revision backfills it.
      triggeredAt: json['triggered_at']?.toString(),
      acknowledgedAt: json['acknowledged_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
    );
  }
}
