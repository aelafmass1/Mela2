import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class CurrencyRateRepository {
  final InterceptedClient client;

  CurrencyRateRepository({required this.client});
  Future<List> fetchCurrencyRate(String accessToken) async {
    // HttpMetric metric = FirebasePerformance.instance
    //     .newHttpMetric('$baseUrl/currency/latest', HttpMethod.Get);
    // metric.start();

    final res = await client.get(
      Uri.parse('$baseUrl/currency/latest'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List rates = data[0]['rates'];
      return rates;
    }
    throw Exception('Failed to fetch currency rate');
  }
}
