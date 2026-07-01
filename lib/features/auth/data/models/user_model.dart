import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.isFirstLogin,
    super.linkedVehicleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:             json['id'] as String,
    email:          json['email'] as String,
    name:           json['name'] as String,
    role:           json['role'] as String,
    isFirstLogin:   json['is_first_login'] as bool? ?? false,
    linkedVehicleId: json['linked_vehicle_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'is_first_login': isFirstLogin,
    'linked_vehicle_id': linkedVehicleId,
  };
}
