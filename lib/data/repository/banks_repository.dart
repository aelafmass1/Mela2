import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class BanksRepository {
  static Future<List> fetchBanks(String accessToken) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/banks',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      return [
        {'error': 'Internal Server Error'}
      ];
    }
    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  static Future<List> fetchBankFee(String accessToken) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/fees/payment-method/all',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as List;

      return data;
    }
    return [processErrorResponse(data)];
  }
}
