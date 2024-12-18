import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class PlaidRepository {
  final InterceptedClient client;

  PlaidRepository({required this.client});

  Future<Map> createLinkToken(String accessToken) async {
    final res = await client.get(
      Uri.parse('$baseUrl/api/plaid/create-link-token'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }
}
