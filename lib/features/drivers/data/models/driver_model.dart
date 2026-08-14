class DriverModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String status; // 'active' | 'inactive' — confirm exact enum via /meta/statuses
  final bool deleted;

  final String? assignedVehiclePlate;
  final int? assignedVehicleId;

  final String? createdAt;
  final String? updatedAt;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.status,
    required this.deleted,
    this.assignedVehiclePlate,
    this.assignedVehicleId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    // NOTE: "active vehicle link" relation shape isn't in the saved
    // Postman examples (empty responses) — parsed defensively, verify
    // field names against the live response and adjust if needed.
    final vehicle = json['vehicle'] ?? json['active_vehicle'];

    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      status: json['status']?.toString() ?? 'active',
      deleted: json['deleted'] ?? false,
      assignedVehiclePlate: vehicle is Map ? vehicle['plate_no']?.toString() : null,
      assignedVehicleId: vehicle is Map ? (vehicle['id'] as num?)?.toInt() : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
