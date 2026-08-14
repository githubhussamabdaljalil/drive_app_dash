import '../../../../core/services/api/api_client.dart';
import '../models/destination_model.dart';

class DestinationRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<DestinationModel>> getDestinations({
    int? driverId,
    int? vehicleId,
    String? status,
  }) async {
    final query = <String>[];
    if (driverId != null) query.add('driver_id=$driverId');
    if (vehicleId != null) query.add('vehicle_id=$vehicleId');
    if (status != null && status.trim().isNotEmpty) {
      query.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }
    final qs = query.isEmpty ? '' : '?${query.join('&')}';

    final res = await _api.get('/admin/manager/destinations$qs');
    final list = res['data'] as List? ?? [];
    return list.map((e) => DestinationModel.fromJson(e)).toList();
  }

  // Pass exactly one of driverId or vehicleId — never both.
  Future<DestinationModel> createDestination({
    int? driverId,
    int? vehicleId,
    required double targetLat,
    required double targetLng,
  }) async {
    final body = <String, dynamic>{
      if (driverId != null) 'driver_id': driverId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      'target_lat': targetLat,
      'target_lng': targetLng,
    };
    final res = await _api.post('/admin/manager/destinations', body);
    return DestinationModel.fromJson(res['data'] ?? res);
  }

  // Only open (sent/accepted) destinations can be updated.
  Future<DestinationModel> updateDestination(
    int id, {
    int? driverId,
    int? vehicleId,
    double? targetLat,
    double? targetLng,
  }) async {
    final body = <String, dynamic>{
      if (driverId != null) 'driver_id': driverId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (targetLat != null) 'target_lat': targetLat,
      if (targetLng != null) 'target_lng': targetLng,
    };
    final res = await _api.patch('/admin/manager/destinations/$id', body);
    return DestinationModel.fromJson(res['data'] ?? res);
  }

  // Soft-transition to "cancelled" (not a hard delete). Notifies the driver.
  Future<void> cancelDestination(int id) async {
    await _api.delete('/admin/manager/destinations/$id');
  }
}
