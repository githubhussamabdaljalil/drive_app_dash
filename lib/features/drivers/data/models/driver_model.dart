class DriverModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? licenseNo;
  final String? licenseExpiry;
  final String status; // 'active' | 'inactive' | 'on_trip'
  final String? companyName;
  final int? companyId;
  final String? assignedVehiclePlate;

  bool get isActive => status == 'active';
  bool get isOnTrip => status == 'on_trip';

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.licenseNo,
    this.licenseExpiry,
    required this.status,
    this.companyName,
    this.companyId,
    this.assignedVehiclePlate,
  });

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
        id: j['id'],
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        licenseNo: j['license_no'],
        licenseExpiry: j['license_expiry'],
        status: j['status'] ?? 'active',
        companyName: j['company']?['name'],
        companyId: j['company_id'],
        assignedVehiclePlate: j['vehicle']?['plate_no'],
      );
}
