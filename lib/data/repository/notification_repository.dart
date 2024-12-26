import 'package:dio/dio.dart';
import '../../core/constants/url_constants.dart';
import '../../core/utils/process_error_response_.dart';

class NotificationRepository {
  final Dio client;

  NotificationRepository({required this.client});

  Future<Map> saveFcmToken({
    required String fcmToken,
  }) async {
    final res = await client.post(saveFcmTokenUrl, data: [
      fcmToken,
    ]);
    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> deleteFcmToken({
    required String fcmToken,
  }) async {
    final res = await client.delete(
      deleteFcmTokenUrl,
      data: fcmToken,
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchNotifications() async {
    final res = await client.get(
      fetchNotificationsUrl,
    );
    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }
}
