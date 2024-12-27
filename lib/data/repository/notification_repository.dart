import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';
import '../../core/constants/url_constants.dart';
import '../../core/utils/process_error_response_.dart';

class NotificationRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  NotificationRepository({required this.client, required this.errorHandler});

  Future<Map> saveFcmToken({
    required String fcmToken,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.post(saveFcmTokenUrl, data: [
        fcmToken,
      ]);
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> deleteFcmToken({
    required String fcmToken,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.delete(
        deleteFcmTokenUrl,
        data: jsonEncode(fcmToken),
      );

      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> fetchNotifications() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get(
        fetchNotificationsUrl,
      );
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }
}
