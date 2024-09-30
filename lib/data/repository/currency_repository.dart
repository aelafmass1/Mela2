import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

import '../../core/exceptions/server_exception.dart';

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
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200) {
      return data.first;
    }
    return processErrorResponse(data);
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
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
