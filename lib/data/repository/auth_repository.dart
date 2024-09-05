import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class AuthRepository {
  static Future<Map> sendOtp(String accessToken, String phoneNumber) async {
    final res =
        await http.post(Uri.parse('$baseUrl/auth/phone/start-verification'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "phoneNumber": phoneNumber,
            }));

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data;
    }
    return {'error': res.body};
  }

  static Future<Map> verifyOtp(
      String accessToken, String phoneNumber, String code) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/phone/verify-code'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            "phoneNumber": phoneNumber,
            "code": code,
          },
        ));

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'error') {
        return {'error': data['message']};
      } else {
        return data;
      }
    }
    return {'error': res.body};
  }
}
