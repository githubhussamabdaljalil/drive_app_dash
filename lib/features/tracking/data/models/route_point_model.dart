/// One point from GET /admin/manager/vehicles/{id}/route-history.
///
/// The Postman collection doesn't ship a saved example body, so this is
/// parsed defensively against the same point shape used everywhere else in
/// the API (`lat`, `lng`, `at` — see FRONTEND_QUICKSTART.md §4-5). Adjust the
/// key names here if the live response turns out to differ.
class RoutePointModel {
  final double lat;
  final double lng;
  final DateTime? at;

  const RoutePointModel({required this.lat, required this.lng, this.at});

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory RoutePointModel.fromJson(Map<String, dynamic> json) {
    return RoutePointModel(
      lat: _num(json['lat']),
      lng: _num(json['lng']),
      at: DateTime.tryParse(json['at']?.toString() ?? ''),
    );
  }
}
