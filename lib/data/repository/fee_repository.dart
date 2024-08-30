import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class FeeRepository {
  static Future<List> fetchFees(String accessToken) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/fees/all'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
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
