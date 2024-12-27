import 'dart:convert';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

/// A repository class for fetching fee data from an API.
class FeeRepository {
  final InterceptedClient client;

  FeeRepository({required this.client});

  /// Fetches a list of fees from the API.
  ///
  /// [accessToken] is the authentication token required for API access.
  ///
  /// Returns a [Future] that completes with a [List] of fee data.
  /// If the API call is successful, it returns the parsed fee data.
  /// If there's an error, it returns a list containing an error map.
  Future<List<dynamic>> fetchFees(String accessToken) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/fees/all'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body) as List<dynamic>;
    if (response.statusCode == 200) {
      return data;
    }
    return [processErrorResponse(jsonDecode(response.body))];
  }

  Future<List> fetchRemittanceExchangeRate(
    String accessToken,
  ) async {
    final res = await client.get(
      Uri.parse('$baseUrl/api/exchange-rates/remittance/active'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
