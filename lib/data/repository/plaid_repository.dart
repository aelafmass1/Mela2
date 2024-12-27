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

  /// Exchanges a public token obtained from the Plaid Link flow for an access token.
  ///
  /// This method sends a POST request to the `/api/plaid/exchange-token` endpoint with the provided `accessToken` and `publicToken`. If the request is successful (status code 200 or 201), it returns a map with a `success` key containing the response body. If the request fails with a 500 status code, it returns a map with an `error` key set to `'Internal Server Error'`. For any other error status code, it returns the processed error response.
  Future<Map> exchangePublicToken(
      String accessToken, String publicToken) async {
    final res = await client.post(
      Uri.parse('$baseUrl/api/plaid/exchange-token'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "publicToken": publicToken,
        },
      ),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': res.body};
    }
    return processErrorResponse(jsonDecode(res.body));
  }

  Future<Map> addBankAccount(String accessToken, String publicToken) async {
    final res = await client.post(
      Uri.parse('$baseUrl/payment-methods/add-bank-account'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "publicToken": publicToken,
        },
      ),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return processErrorResponse(jsonDecode(res.body));
  }
}
