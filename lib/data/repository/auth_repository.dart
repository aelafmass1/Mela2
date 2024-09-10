import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

class AuthRepository {
  static Future<Map> registerUser(UserModel user) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/auth/register',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        user.toMap(),
      ),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }

    return {'error': data['errorResponse'].first['message']};
  }

  static Future<Map> loginUser({
    required int phoneNumber,
    required int countryCode,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/auth/login',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "countryCode": countryCode,
        "phoneNumber": phoneNumber,
        "password": password,
        "phoneNumberLogin": true
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }

    return {'error': data['message']};
  }

  static Future<Map> deleteUser(
      String accessToken, String phoneNumber, String code) async {
    return {};
  }

  static Future<Map> setPincode(String accessToken, String pincode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/set-pin'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "pin": pincode,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data;
    }
    return {'error': res.body};
  }

  static Future<Map> verfiyPincode(String accessToken, String pincode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/confirm-pin'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "pin": pincode,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return {'error': data['message']};
  }

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
