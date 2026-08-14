class GuestCodeModel {
  final int id;
  final String code;
  final int vehicleId;
  final String? vehiclePlate;
  final String status; // active | expired | revoked — confirm exact enum via /meta/statuses
  final String? expiresAt;
  final String? createdAt;

  const GuestCodeModel({
    required this.id,
    required this.code,
    required this.vehicleId,
    this.vehiclePlate,
    required this.status,
    this.expiresAt,
    this.createdAt,
  });

  bool get isActive => status == 'active';

  factory GuestCodeModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'];
    return GuestCodeModel(
      id: json['id'] ?? 0,
      code: json['code']?.toString() ?? '',
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? 0,
      vehiclePlate: vehicle is Map ? vehicle['plate_no']?.toString() : null,
      status: json['status']?.toString() ?? 'active',
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
