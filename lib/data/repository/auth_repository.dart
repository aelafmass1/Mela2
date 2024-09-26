import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_response_body.dart';
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
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    if (data.containsKey('errorResponse')) {
      return {'error': data['errorResponse'].first['message'], 'data': data};
    }
    if (data.containsKey('message')) {
      return {'error': data['message']};
    }
    return processErrorResponse(data);
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
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }

    return processErrorResponse(data);
  }

  static Future<Map> loginWithPincode({
    required String pincode,
    required int phoneNumber,
    required int countryCode,
  }) async {
    final res = await http.post(
      Uri.parse(
        '$baseUrl/auth/login-by-pin',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "countryCode": countryCode,
        "phoneNumber": phoneNumber,
        "pin": pincode,
      }),
    );
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }
    final data = jsonDecode(res.body) as Map;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }

  static Future<Map> deleteUser(
      String accessToken, String phoneNumber, String code) async {
    return {
      //
    };
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
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
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
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }

  static Future<Map> sendOtp(int phoneNumber, int countryCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/phone/start-verification'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
        },
      ),
    );
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data.containsKey('status')) {
        if (data['message'] == 'Failed to send SMS.') {
          return {'error': 'Failed to send SMS'};
        }
        if (data['status'] == 'error') {
          return processErrorResponse(data);
        }
      }
      return data;
    }
    return processErrorResponse(data);
  }

  static Future<Map> verifyOtp({
    required int phoneNumber,
    required String code,
    required int countryCode,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/phone/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            "countryCode": countryCode,
            "phoneNumber": phoneNumber,
            "code": code,
          },
        ));
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data['status'] == 'error') {
        return {'error': data['message']};
      } else {
        return data;
      }
    }
    return processErrorResponse(data);
  }

  static Future<Map> sendOtpForPasswordReset(
      int phoneNumber, int countryCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/password/forgot/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {"countryCode": countryCode, "phoneNumber": phoneNumber},
      ),
    );
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data.containsKey('status')) {
        if (data['message'] == 'Failed to send SMS.') {
          return {'error': 'Failed to send SMS'};
        }
        if (data['status'] == 'error') {
          return processErrorResponse(data);
        }
      }
      return data;
    }
    return processErrorResponse(data);
  }

  static Future<Map> sendOtpForPincodeReset(
      int phoneNumber, int countryCode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/pin/forgot/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {"countryCode": countryCode, "phoneNumber": phoneNumber},
      ),
    );
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data.containsKey('status')) {
        if (data['message'] == 'Failed to send SMS.') {
          return {'error': 'Failed to send SMS'};
        }
        if (data['status'] == 'error') {
          return processErrorResponse(data);
        }
      }
      return data;
    }
    return processErrorResponse(data);
  }

  static Future<Map> resetPassword({
    required int phoneNumber,
    required String otp,
    required int countryCode,
    required String newPassword,
  }) async {
    final res =
        await http.post(Uri.parse('$baseUrl/auth/password/forgot/reset'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "countryCode": countryCode,
              "phoneNumber": phoneNumber,
              "otpCode": otp,
              "newPassword": newPassword,
            }));
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data['status'] == 'error') {
        return {'error': data['message']};
      } else {
        return data;
      }
    }
    return processErrorResponse(data);
  }

  static Future<Map> resetPincode({
    required int phoneNumber,
    required String otp,
    required int countryCode,
    required String newPassword,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/pin/forgot/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "otpCode": otp,
          "newPassword": newPassword,
        }));
    if (res.statusCode == 500) {
      return {'error': 'Unexpected error'};
    }

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data['status'] == 'error') {
        return {'error': data['message']};
      } else {
        return data;
      }
    }
    return processErrorResponse(data);
  }
}
