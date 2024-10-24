import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

/// Repository class responsible for interacting with payment intent related API endpoints.
class PaymentIntentRepository {
  InterceptedClient client;

  PaymentIntentRepository({required this.client});

  /// Creates a payment intent on the server.
  ///
  /// [currency] - The currency of the payment intent.
  /// [amount] - The amount of the payment intent.
  /// [accessToken] - The access token of the authenticated user.
  ///
  /// Returns a [Map] containing the payment intent details if successful, otherwise returns a [Map] with an error message.
  Future<Map> createPaymentIntent({
    required String currency,
    required String accessToken,
    required double amount,
  }) async {
    final res = await client.post(
      Uri.parse('$baseUrl/payment/create-intent'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "amount": amount,
          "currency": currency,
        },
      ),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }
}
