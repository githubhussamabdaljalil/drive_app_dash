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

  // ID of the company's manager
  final int? managerId;

  final String? managerEmail;

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
    this.managerEmail,
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
    // ==========================================================
    // MANAGER
    // ==========================================================

    final managers = json['managers'];

    int? managerId;
    String? managerEmail;

    if (managers is List && managers.isNotEmpty) {
      final manager = managers.first;

      if (manager is Map<String, dynamic>) {
        managerId = int.tryParse(
          manager['id']?.toString() ?? '',
        );

        managerEmail = manager['email']?.toString();
      }
    }

    // ==========================================================
    // COMPANY
    // ==========================================================

    return CompanyModel(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,

      name: json['name']?.toString() ?? '',

      commercialNo:
          json['commercial_no']?.toString(),

      expiryDate:
          json['expiry_date']?.toString(),

      status:
          json['status']?.toString() ?? 'active',

      deleted:
          json['deleted'] == true,

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

      managerId: managerId,

      managerEmail: managerEmail,

      createdAt:
          json['created_at']?.toString(),

      updatedAt:
          json['updated_at']?.toString(),
    );
  }
}