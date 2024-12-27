import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

class AuthRepository {
  InterceptedClient client;
  AuthRepository({required this.client});

  /// Registers a new user with the provided [UserModel] data.
  ///
  /// This method sends a POST request to the '/auth/register' endpoint with the user data
  /// encoded in the request body as JSON. If the request is successful (status code 200 or 201),
  /// the method returns the response data as a [Map]. If the request fails, the method returns
  /// a [Map] containing an 'error' key with the error message.
  ///
  /// Throws an 'Unexpected error' error if the server responds with a 500 status code.
  ///
  /// Parameters:
  /// - [user]: The [UserModel] containing the user data to be registered.
  ///
  /// Returns:
  /// A [Map] containing the response data or an error message.
  Future<Map> registerUser(UserModel user) async {
    final res = await client.post(
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

    return processErrorResponse(data);
  }

  /// Logs in a user with the provided phone number, country code, and password.
  ///
  /// This method sends a POST request to the '/auth/login' endpoint with the user credentials
  /// encoded in the request body as JSON. If the request is successful (status code 200 or 201),
  /// the method returns the response data as a [Map]. If the request fails, the method returns
  /// a [Map] containing an 'error' key with the error message.
  ///
  /// Throws an 'Unexpected error' error if the server responds with a 500 status code.
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number of the user.
  /// - [countryCode]: The country code of the user's phone number.
  /// - [password]: The password of the user.
  ///
  /// Returns:
  /// A [Map] containing the response data or an error message.
  Future<Map> loginUser({
    required int phoneNumber,
    required int countryCode,
    required String password,
  }) async {
    final res = await client.post(
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
        "phoneNumberLogin": true,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }

    return processErrorResponse(data);
  }

  /// Logs in a user with the provided pin code, phone number, and country code.
  ///
  /// This method sends a POST request to the '/auth/login-by-pin' endpoint with the user credentials
  /// encoded in the request body as JSON. If the request is successful (status code 200 or 201),
  /// the method returns the response data as a [Map]. If the request fails, the method returns
  /// a [Map] containing an 'error' key with the error message.
  ///
  /// Throws an 'Unexpected error' error if the server responds with a 500 status code.
  ///
  /// Parameters:
  /// - [pincode]: The pin code of the user.
  /// - [phoneNumber]: The phone number of the user.
  /// - [countryCode]: The country code of the user's phone number.
  ///
  /// Returns:
  /// A [Map] containing the response data or an error message.
  Future<Map> loginWithPincode({
    required String pincode,
    required int phoneNumber,
    required int countryCode,
  }) async {
    final res = await client.post(
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

    final data = jsonDecode(res.body) as Map;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> setPincode(String accessToken, String pincode) async {
    final res = await client.post(
      Uri.parse('$baseUrl/auth/set-pin'),
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
    return processErrorResponse(data);
  }

  Future<Map> verfiyPincode(String accessToken, String pincode) async {
    final res = await client.post(
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
    return processErrorResponse(data);
  }

  /// Sends an OTP (One-Time Password) to the specified phone number and country code.
  ///
  /// This method sends a POST request to the `/auth/phone/start-verification` endpoint with the provided phone number and country code.
  ///
  /// If the OTP is sent successfully, the method returns a map containing the response data.
  /// If there is an error, the method returns a map with an 'error' key containing the error message.
  ///
  /// Parameters:
  /// - `phoneNumber`: The phone number to send the OTP to.
  /// - `countryCode`: The country code of the phone number.
  ///
  /// Returns:
  /// A `Future<Map>` containing the response data or an error message.
  Future<Map> sendOtp(
      int phoneNumber, int countryCode, String signature) async {
    final res = await client.post(
      Uri.parse('$baseUrl/auth/phone/start-verification'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
          "signature": signature,
        },
      ),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data.containsKey('status')) {
        if (data['message'] == 'Failed to send SMS.') {
          return {
            'error': 'Failed to send SMS',
            'userId': data['errorResponse']
          };
        }
        if (data['status'] == 'error') {
          return processErrorResponse(data);
        }
      }
      return data;
    }
    if (data['message'] == 'Failed to send SMS.') {
      return {'error': 'Failed to send SMS', 'userId': data['errorResponse']};
    }
    return processErrorResponse(data);
  }

  /// Verifies an OTP (One-Time Password) for a given phone number and country code.
  ///
  /// This method sends a POST request to the `/auth/phone/verify-otp` endpoint with the provided phone number, country code, and OTP code.
  ///
  /// If the OTP is verified successfully, the method returns a map containing the response data.
  /// If there is an error, the method returns a map with an 'error' key containing the error message.
  ///
  /// Parameters:
  /// - `phoneNumber`: The phone number to verify the OTP for.
  /// - `code`: The OTP code to verify.
  /// - `countryCode`: The country code of the phone number.
  ///
  /// Returns:
  /// A `Future<Map>` containing the response data or an error message.
  Future<Map> verifyOtp({
    required int phoneNumber,
    required String code,
    required int countryCode,
  }) async {
    final res = await client.post(Uri.parse('$baseUrl/auth/phone/verify-otp'),
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

  /// Sends an OTP (One-Time Password) to the provided phone number for password reset.
  ///
  /// This method sends a POST request to the `/auth/password/forgot/request-otp` endpoint with the provided phone number and country code.
  ///
  /// If the OTP is sent successfully, the method returns a map containing the response data.
  /// If there is an error, the method returns a map with an 'error' key containing the error message.
  ///
  /// Parameters:
  /// - `phoneNumber`: The phone number to send the OTP to.
  /// - `countryCode`: The country code of the phone number.
  ///
  /// Returns:
  /// A `Future<Map>` containing the response data or an error message.
  Future<Map> sendOtpForPasswordReset(
      int phoneNumber, int countryCode, String signature) async {
    final res = await client.post(
      Uri.parse('$baseUrl/auth/password/forgot/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "signature": signature,
        },
      ),
    );

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

  /// Sends an OTP (One-Time Password) to the provided phone number for pincode reset.
  ///
  /// This method sends a POST request to the `/auth/pin/forgot/request-otp` endpoint with the provided phone number and country code.
  ///
  /// If the OTP is sent successfully, the method returns a map containing the response data.
  /// If there is an error, the method returns a map with an 'error' key containing the error message.
  ///
  /// Parameters:
  /// - `phoneNumber`: The phone number to send the OTP to.
  /// - `countryCode`: The country code of the phone number.
  ///
  /// Returns:
  /// A `Future<Map>` containing the response data or an error message.
  Future<Map> sendOtpForPincodeReset(
    int phoneNumber,
    int countryCode,
    String signature,
    String accessToken,
  ) async {
    final res = await post(
      Uri.parse('$baseUrl/auth/pin/forgot/request-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        {
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "signature": signature,
        },
      ),
    );

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

  /// Resets the user's password by sending an OTP and allowing the user to set a new password.
  ///
  /// This method sends a POST request to the `/auth/password/forgot/reset` endpoint with the following parameters:
  /// - `countryCode`: The country code of the user's phone number.
  /// - `phoneNumber`: The user's phone number.
  /// - `otpCode`: The one-time password (OTP) sent to the user's phone.
  /// - `newPassword`: The new password the user wants to set.
  ///
  /// If the request is successful (status code 200 or 201), the method returns the response data. If the response has a 'status' field with a value of 'error', the method returns an error object with the error message. If the request fails (status code 500), the method returns an error object with the message 'Unexpected error'.
  ///
  /// The method uses the `http` package to make the POST request and the `jsonDecode` function to parse the response body.
  Future<Map> resetPassword({
    required int phoneNumber,
    required String otp,
    required int countryCode,
    required String newPassword,
  }) async {
    final res =
        await client.post(Uri.parse('$baseUrl/auth/password/forgot/reset'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "countryCode": countryCode,
              "phoneNumber": phoneNumber,
              "otpCode": otp,
              "newPassword": newPassword,
            }));

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

  /// Resets the user's pincode by sending an OTP and allowing the user to set a new pincode.
  ///
  /// This method sends a POST request to the `/auth/pin/forgot/reset` endpoint with the following parameters:
  /// - `countryCode`: The country code of the user's phone number.
  /// - `phoneNumber`: The user's phone number.
  /// - `otpCode`: The one-time password (OTP) sent to the user's phone.
  /// - `newPin`: The new pincode the user wants to set.
  ///
  /// If the request is successful (status code 200 or 201), the method returns the response data. If the response has a 'status' field with a value of 'error', the method returns an error object with the error message. If the request fails (status code 500), the method returns an error object with the message 'Unexpected error'.
  ///
  /// The method uses the `http` package to make the POST request and the `jsonDecode` function to parse the response body.
  Future<Map> resetPincode({
    required int phoneNumber,
    required String otp,
    required int countryCode,
    required String newPincode,
  }) async {
    final res = await client.post(Uri.parse('$baseUrl/auth/pin/forgot/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "otpCode": otp,
          "newPin": newPincode
        }));

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

  /// Deletes the current user's account.
  ///
  /// This method sends a DELETE request to the `/user/me/delete` endpoint with the provided access token in the `Authorization` header.
  ///
  /// If the request is successful (status code 200), the method returns the response data. If the request fails, the method returns an error object with the error message.
  ///
  /// The method uses the `http` package to make the DELETE request and the `jsonDecode` function to parse the response body.
  Future<Map> deleteUser({required String accessToken}) async {
    final res = await client.delete(
      Uri.parse('$baseUrl/user/me/delete'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> checkEmailExists(String email) async {
    final res = await client.post(
      Uri.parse('$baseUrl/auth/email/exists?email=$email'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      if (data['message'] == 'Email already exists.') {
        return processErrorResponse(data);
      }
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchMe({required String accessToken}) async {
    final res = await client.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data;
    }

    return processErrorResponse(data);
  }
}
