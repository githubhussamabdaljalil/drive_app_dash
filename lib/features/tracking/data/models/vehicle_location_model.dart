/// One `location.updated` socket payload (FRONTEND_QUICKSTART.md §4):
/// `{"vehicle_id":3,"driver_id":9,"lat":33.5178,"lng":36.2765,"at":"..."}`
class VehicleLocationModel {
  final int vehicleId;
  final int? driverId;
  final double lat;
  final double lng;
  final DateTime? at;

  const VehicleLocationModel({
    required this.vehicleId,
    this.driverId,
    required this.lat,
    required this.lng,
    this.at,
  });

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory VehicleLocationModel.fromJson(Map<String, dynamic> json) {
    return VehicleLocationModel(
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? 0,
      driverId: (json['driver_id'] as num?)?.toInt(),
      lat: _num(json['lat']),
      lng: _num(json['lng']),
      at: DateTime.tryParse(json['at']?.toString() ?? ''),
    );
  }
}
