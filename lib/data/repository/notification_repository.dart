import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';

import '../../core/constants/url_constants.dart';
import '../../core/utils/process_error_response_.dart';

class NotificationRepository {
  final InterceptedClient client;

  NotificationRepository({required this.client});

  Future<Map> saveFcmToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    final res = await client.post(
        Uri.parse(
          '$baseUrl/user/me/devices',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode([
          fcmToken,
        ]));

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> deleteFcmToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    final res = await client.delete(
        Uri.parse(
          '$baseUrl/user/me/devices',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          fcmToken,
        ));

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchNotifications({
    required String accessToken,
  }) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/notifications/all',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }
}
