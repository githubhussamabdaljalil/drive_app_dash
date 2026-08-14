import '../../../../core/services/api/api_client.dart';
import '../models/sos_event_model.dart';

class SosRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<SosEventModel>> getSosEvents({String? status}) async {
    final qs = (status != null && status.trim().isNotEmpty) ? '?status=${Uri.encodeQueryComponent(status.trim())}' : '';
    final res = await _api.get('/admin/manager/sos-events$qs');
    final list = res['data'] as List? ?? [];
    return list.map((e) => SosEventModel.fromJson(e)).toList();
  }

  // Confirms the alert was seen, cancels the 60s re-alert. 409 if not Active.
  Future<SosEventModel> acknowledge(int id) async {
    final res = await _api.patch('/admin/manager/sos-events/$id/acknowledge', {});
    return SosEventModel.fromJson(res['data'] ?? res);
  }

  // Marks the emergency closed. 409 if already resolved.
  Future<SosEventModel> resolve(int id) async {
    final res = await _api.patch('/admin/manager/sos-events/$id/resolve', {});
    return SosEventModel.fromJson(res['data'] ?? res);
  }
}
