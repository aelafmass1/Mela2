import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class CurrencyRateRepository {
  static Future<List> fetchCurrencyRate(String accessToken) async {
    // HttpMetric metric = FirebasePerformance.instance
    //     .newHttpMetric('$baseUrl/currency/latest', HttpMethod.Get);
    // metric.start();

    final res = await http.get(
      Uri.parse('$baseUrl/currency/latest'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    // metric.stop();

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List rates = data[0]['rates'];
      return rates;
    }
    throw Exception('Failed to fetch currency rate');
  }
}
