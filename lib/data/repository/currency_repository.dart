import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class CurrencyRepository {
  static Future<Map<String, dynamic>> fetchPromotionalCurrency(
      String accessToken) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/exchange-rates',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'currencyCode': 'USD',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.first;
    }
    return {'error': res.body};
  }

  static Future<List> fetchCurrencies(
    String accessToken,
  ) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/exchange-rates',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'currencyCode': '',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data;
    }
    return [
      {'error': res.body}
    ];
  }
}
