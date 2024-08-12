import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class CurrencyRateRepository {
  static Future<List> fetchCurrencyRate() async {
    final res = await http.get(Uri.parse('$baseUrl/currency/latest'));
    if (res.statusCode == 200) {
      List rates = jsonDecode(res.body)[0]['rates'];
      return rates;
    }
    throw Exception('Failed to fetch currency rate');
  }
}
