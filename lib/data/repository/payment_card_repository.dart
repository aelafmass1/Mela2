import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';

class PaymentCardRepository {
  final InterceptedClient client;

  PaymentCardRepository({required this.client});

  /// Adds a new payment card to the user's account.
  ///
  /// This method sends a POST request to the `$baseUrl/payment-methods/add-card` endpoint
  /// with the provided `accessToken` in the `Authorization` header and the `token` parameter
  /// in the request body. If the request is successful (status code 200 or 201), the method
  /// returns the decoded JSON response data. If the request returns a 500 status code, the
  /// method returns an error map with the message 'Internal Server Error'. Otherwise, it
  /// returns the error response processed by the `processErrorResponse` function.
  ///
  /// Parameters:
  /// - `accessToken`: The access token required to authenticate the request.
  /// - `token`: The token representing the payment card to be added.
  ///
  /// Returns:
  /// A `Future<Map<String, dynamic>>` containing the payment card data or an error response.
  Future<Map> addPaymentCard({
    required String token,
  }) async {
    final accessToken = await getToken();

    final res = await client.post(
      Uri.parse('$baseUrl/payment-methods/add-card'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "token": token,
        },
      ),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> addBankAccount(String publicToken) async {
    final token = await getToken();

    final res = await client.post(
      Uri.parse('$baseUrl/payment-methods/add-bank-account'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "publicToken": publicToken,
        },
      ),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return processErrorResponse(jsonDecode(res.body));
  }

  /// Fetches a list of payment cards associated with the provided access token.
  ///
  /// This method sends a GET request to the `$baseUrl/payment-methods/list` endpoint
  /// with the provided `accessToken` in the `Authorization` header. If the request
  /// is successful (status code 200 or 201), the method returns the decoded JSON
  /// response data. Otherwise, it returns a list containing the error response
  /// processed by the `processErrorResponse` function.
  ///
  /// Parameters:
  /// - `accessToken`: The access token required to authenticate the request.
  ///
  /// Returns:
  /// A `Future<List>` containing the payment card data or an error response.
  Future<List> fetchPaymentCards({
    required String accessToken,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl/payment-methods/list'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint("the datas: $data");
      return data;
    }
    return [processErrorResponse(data)];
  }
}
