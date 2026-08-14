import '../../../../core/services/api/api_client.dart';
import '../models/route_point_model.dart';

class RouteHistoryRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  /// GET /admin/manager/vehicles/{id}/route-history?from=<ISO>&to=<ISO>
  /// Returns discrete points in order — the caller draws the polyline.
  Future<List<RoutePointModel>> getRouteHistory({
    required int vehicleId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromIso = from.toUtc().toIso8601String();
    final toIso = to.toUtc().toIso8601String();
    final qs = '?from=${Uri.encodeQueryComponent(fromIso)}&to=${Uri.encodeQueryComponent(toIso)}';

    final res = await _api.get('/admin/manager/vehicles/$vehicleId/route-history$qs');
    final list = res['data'] as List? ?? [];
    return list.map((e) => RoutePointModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
