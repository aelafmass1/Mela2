import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class PlaidRepository {
  static Future<Map> createLinkToken(String accessToken) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/plaid/create-link-token'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data;
    }
    return {'error': res.body};
  }

  static Future<Map> exchangePublicToken(
      String accessToken, String publicToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/plaid/exchange-token'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "publicToken": publicToken,
        },
      ),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': res.body};
    }
    return {'error': res.body};
  }
}
