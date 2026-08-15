class CompanyModel {
  final int id;
  final String name;
  final String? commercialNo;
  final String? expiryDate;
  final String status;
  final bool deleted;

  final int managersCount;
  final int driversCount;
  final int vehiclesCount;

  final int? managerId;
  final String? createdAt;
  final String? updatedAt;

  const CompanyModel({
    required this.id,
    required this.name,
    this.commercialNo,
    this.expiryDate,
    required this.status,
    required this.deleted,
    required this.managersCount,
    required this.driversCount,
    required this.vehiclesCount,
    this.managerId,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // STATUS
  // ============================================================

  bool get isActive => status == 'active';

  // ============================================================
  // FROM JSON
  // ============================================================

  factory CompanyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyModel(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      commercialNo: json['commercial_no']?.toString(),

      expiryDate: json['expiry_date']?.toString(),

      status: json['status']?.toString() ?? 'active',

      deleted: json['deleted'] ?? false,

      managersCount:
          int.tryParse(
            json['managers_count']?.toString() ?? '0',
          ) ??
          0,

      driversCount:
          int.tryParse(
            json['drivers_count']?.toString() ?? '0',
          ) ??
          0,

      vehiclesCount:
          int.tryParse(
            json['vehicles_count']?.toString() ?? '0',
          ) ??
          0,

      managerId: json['manager_id'] != null
          ? int.tryParse(json['manager_id'].toString())
          : null,

      createdAt: json['created_at']?.toString(),

      updatedAt: json['updated_at']?.toString(),
    );
  }
}