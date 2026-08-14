class DestinationModel {
  final int id;
  final int? driverId;
  final int? vehicleId;
  final double targetLat;
  final double targetLng;
  final String status; // e.g. sent | accepted | rejected | cancelled | completed
  final String? driverName;
  final String? vehiclePlate;
  final String? createdAt;

  const DestinationModel({
    required this.id,
    this.driverId,
    this.vehicleId,
    required this.targetLat,
    required this.targetLng,
    required this.status,
    this.driverName,
    this.vehiclePlate,
    this.createdAt,
  });

  bool get isOpen => status == 'sent' || status == 'accepted';

  // NOTE (FRONTEND_QUICKSTART §7 "Gotchas"): target_lat/target_lng come
  // back from the API as STRINGS — always parse them.
  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final vehicle = json['vehicle'];
    return DestinationModel(
      id: json['id'] ?? 0,
      driverId: (json['driver_id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      targetLat: _num(json['target_lat']),
      targetLng: _num(json['target_lng']),
      status: json['status']?.toString() ?? 'sent',
      driverName: driver is Map ? driver['name']?.toString() : null,
      vehiclePlate: vehicle is Map ? vehicle['plate_no']?.toString() : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}
