import 'dart:convert';

import 'package:http/http.dart' as http;

/// Repository class responsible for interacting with payment intent related API endpoints.
class PaymentIntentRepository {
  /// Creates a payment intent on the server.
  ///
  /// [currency] - The currency of the payment intent.
  /// [amount] - The amount of the payment intent.
  /// [accessToken] - The access token of the authenticated user.
  ///
  /// Returns a [Map] containing the payment intent details if successful, otherwise returns a [Map] with an error message.
  static Future<Map> createPaymentIntent({
    required String currency,
    required double amount,
    required String accessToken,
  }) async {
    final res = await http.post(
      Uri.parse(
          'https://55f6-71-191-150-39.ngrok-free.app/payment/create-intent'),
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
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return {'error': res.body};
  }
}
