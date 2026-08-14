class PermissionOption {
  final String value;
  final String label;
  final String labelAr;

  const PermissionOption({required this.value, required this.label, required this.labelAr});

  factory PermissionOption.fromJson(Map<String, dynamic> json) => PermissionOption(
        value: json['value']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        labelAr: json['label_ar']?.toString() ?? json['label']?.toString() ?? '',
      );
}

class SubManagerModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool deleted;
  final List<String> permissions;

  const SubManagerModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.deleted,
    required this.permissions,
  });

  factory SubManagerModel.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] as List? ?? [];
    return SubManagerModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      deleted: json['deleted'] ?? false,
      permissions: rawPermissions.map((e) => e.toString()).toList(),
    );
  }
}
