class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? companyId;
  final bool mustChangePassword;
  final List<String> permissions;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.companyId,
    required this.mustChangePassword,
    required this.permissions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      companyId: json['company_id'],
      mustChangePassword: json['must_change_password'] ?? false,
      permissions: json['permissions'] is List
          ? List<String>.from(
              json['permissions'].map(
                (e) => e.toString(),
              ),
            )
          : [],
    );
  }
}