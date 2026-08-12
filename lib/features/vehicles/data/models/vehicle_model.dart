class VehicleModel {
  final int id;
  final String plateNo;
  final String type; // 'bus' | 'van' | 'truck' | 'car'
  final String? brand;
  final String? model;
  final int? year;
  final String status; // 'active' | 'inactive' | 'on_trip' | 'maintenance'
  final String? companyName;
  final int? companyId;
  final String? assignedDriverName;

  bool get isActive => status == 'active';
  bool get isOnTrip => status == 'on_trip';
  bool get isInMaintenance => status == 'maintenance';

  const VehicleModel({
    required this.id,
    required this.plateNo,
    required this.type,
    this.brand,
    this.model,
    this.year,
    required this.status,
    this.companyName,
    this.companyId,
    this.assignedDriverName,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> j) => VehicleModel(
        id: j['id'],
        plateNo: j['plate_no'] ?? '',
        type: j['type'] ?? 'car',
        brand: j['brand'],
        model: j['model'],
        year: j['year'],
        status: j['status'] ?? 'active',
        companyName: j['company']?['name'],
        companyId: j['company_id'],
        assignedDriverName: j['driver']?['name'],
      );
}
