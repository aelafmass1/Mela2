import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class CurrencyRepository {
  final InterceptedClient client;

  CurrencyRepository({required this.client});
  Future<Map<String, dynamic>> fetchPromotionalCurrency(
      String accessToken) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/exchange-rates',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'currencyCode': 'USD',
      },
    );

    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200) {
      return data.first;
    }
    return processErrorResponse(data);
  }

  Future<List> fetchCurrencies(
    String accessToken,
  ) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/exchange-rates',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'currencyCode': '',
      },
    );

    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
