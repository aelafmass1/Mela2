import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class TransactionRepository {
  final InterceptedClient client;

  TransactionRepository({required this.client});
  Future<Map<String, dynamic>> fetchTransaction(String accessToken) async {
    final res = await client.get(
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
    return processErrorResponse(jsonDecode(res.body));
  }
}
