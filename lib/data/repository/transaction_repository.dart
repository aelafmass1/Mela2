import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

class TransactionRepository {
  static Future<Map<String, dynamic>> fetchTransaction(
      String accessToken, String uid) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/money-transfer/transactions',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      List data = [];
      if (res.body.isNotEmpty) {
        data = jsonDecode(res.body);
      } else {
        data = [];
      }
      return {'success': data};
    }
    return {"error": res.body.isEmpty ? 'please try again' : res.body};
  }
}
