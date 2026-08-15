import '../../../../core/services/api/api_client.dart';
import '../models/guest_tracking_model.dart';

class GuestTrackingRemoteDataSource {
  final ApiClient _api = ApiClient.instance;

  Future<GuestTrackingModel> track(String guestCode) async {
    final response = await _api.get(
      '/guest/track/$guestCode',
      auth: false,
    );
    return GuestTrackingModel.fromJson(
      Map<String, dynamic>.from(response['data'] ?? response),
    );
  }
}
