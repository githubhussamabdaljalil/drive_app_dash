/// Role constants
class UserRole {
  static const String owner   = 'owner';
  static const String manager = 'manager';
  static const String driver  = 'driver';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;          // owner | manager | driver
  final bool isFirstLogin;    // must_change_password flag from API
  final String? phone;
  final String? vehiclePlate; // driver only

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isFirstLogin,
    this.phone,
    this.vehiclePlate,
  });

  factory UserModel.fromAdminJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return UserModel(
      id:           user['id'].toString(),
      name:         user['name'] ?? '',
      email:        user['email'] ?? '',
      role:         user['role'] ?? UserRole.manager,
      isFirstLogin: user['must_change_password'] == true,
    );
  }

  factory UserModel.fromDriverJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final vehicle = user['vehicle'];
    return UserModel(
      id:           user['id'].toString(),
      name:         user['name'] ?? '',
      email:        user['email'] ?? user['phone'] ?? '',
      role:         UserRole.driver,
      isFirstLogin: user['must_change_password'] == true,
      phone:        user['phone'],
      vehiclePlate: vehicle?['plate_number'],
    );
  }
}
