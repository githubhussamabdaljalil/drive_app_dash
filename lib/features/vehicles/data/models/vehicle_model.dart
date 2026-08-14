class VehicleModel {
  final int id;
  final String plateNo;
  final String? type;
  final String? model;
  final String? description;
  final String status; // 'active' | 'inactive' | 'maintenance' | 'out_of_service' (active/inactive are server-computed)
  final bool deleted;

  final String? assignedDriverName;
  final int? assignedDriverId;

  final String? createdAt;
  final String? updatedAt;

  const VehicleModel({
    required this.id,
    required this.plateNo,
    this.type,
    this.model,
    this.description,
    required this.status,
    required this.deleted,
    this.assignedDriverName,
    this.assignedDriverId,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // STATUS
  // ============================================================

  bool get isActive => status == 'active';
  bool get isMaintenance => status == 'maintenance';
  bool get isOutOfService => status == 'out_of_service';

  // Only these two values are ever admin-settable via PATCH.
  // active/inactive are computed by the server from driver check-in +
  // vehicle link state — see VTFMS API docs ("Update Vehicle").
  static const settableStatuses = ['maintenance', 'out_of_service'];

  // ============================================================
  // FROM JSON
  // ============================================================

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // NOTE: `driver` relation shape is not documented in the Postman
    // collection response examples (they were saved empty). Parsed
    // defensively here — verify field names against the live response
    // the first time this hits the real server and adjust if needed.
    final driver = json['driver'] ?? json['assigned_driver'];

    return VehicleModel(
      id: json['id'] ?? 0,
      plateNo: json['plate_no']?.toString() ?? '',
      type: json['type']?.toString(),
      model: json['model']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'inactive',
      deleted: json['deleted'] ?? false,
      assignedDriverName: driver is Map ? driver['name']?.toString() : null,
      assignedDriverId: driver is Map ? (driver['id'] as num?)?.toInt() : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
