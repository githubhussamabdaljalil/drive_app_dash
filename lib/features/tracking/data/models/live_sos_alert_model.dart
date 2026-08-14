/// One `sos.triggered` socket payload (FRONTEND_QUICKSTART.md §4):
/// `{"id":1,"driver_id":9,"vehicle_id":3,"lat":33.52,"lng":36.28,
///   "triggered_at":"...","is_re_alert":false}`
///
/// Kept separate from `SosEventModel` (features/sos) on purpose: that one
/// models the REST list where `triggered_at` is always null per the docs —
/// this one models the live push where it's the only place that field is
/// actually populated.
class LiveSosAlertModel {
  final int id;
  final int? driverId;
  final int? vehicleId;
  final double lat;
  final double lng;
  final DateTime? triggeredAt;
  final bool isReAlert;

  const LiveSosAlertModel({
    required this.id,
    this.driverId,
    this.vehicleId,
    required this.lat,
    required this.lng,
    this.triggeredAt,
    required this.isReAlert,
  });

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory LiveSosAlertModel.fromJson(Map<String, dynamic> json) {
    return LiveSosAlertModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      driverId: (json['driver_id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      lat: _num(json['lat']),
      lng: _num(json['lng']),
      triggeredAt: DateTime.tryParse(json['triggered_at']?.toString() ?? ''),
      isReAlert: json['is_re_alert'] == true,
    );
  }
}
