import '../../../../core/services/api/api_client.dart';
import '../models/manager_notification_model.dart';

class ManagerNotificationRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<List<ManagerNotificationModel>> getNotifications() async {
    final res = await _api.get('/admin/manager/notifications');
    final list = res['data'] as List? ?? [];
    return list.map((e) => ManagerNotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(int id) async {
    await _api.patch('/admin/manager/notifications/$id/read', {});
  }
}
