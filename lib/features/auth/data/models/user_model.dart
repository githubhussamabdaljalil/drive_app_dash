/// Role constants (admin roles only — driver/guest are a separate app)
class UserRole {
  static const String owner   = 'owner';
  static const String manager = 'manager';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // owner | manager
  final bool isFirstLogin; // must_change_password flag from API

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isFirstLogin,
  });

  factory UserModel.fromAdminJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return UserModel(
      id: user['id'].toString(),
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? UserRole.manager,
      isFirstLogin: user['must_change_password'] == true,
    );
  }
}
