import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class PaymentCardRepository {
  static Future<Map<String, dynamic>> addPaymentCard({
    required String accessToken,
    required String token,
  }) async {
    final res = await http.post(
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
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return {'error': res.body};
  }

  static Future<List<Map<String, dynamic>>> fetchPaymentCards({
    required String accessToken,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/payment-methods/list'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return [
      {'error': res.body}
    ];
  }
}
