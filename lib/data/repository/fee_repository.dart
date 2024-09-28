import 'dart:convert';
import 'package:http/http.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';

/// A repository class for fetching fee data from an API.
class FeeRepository {
  final Client client;

  FeeRepository({required this.client});

  /// Fetches a list of fees from the API.
  ///
  /// [accessToken] is the authentication token required for API access.
  ///
  /// Returns a [Future] that completes with a [List] of fee data.
  /// If the API call is successful, it returns the parsed fee data.
  /// If there's an error, it returns a list containing an error map.
  Future<List<dynamic>> fetchFees(String accessToken) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/fees/all'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data;
      } else {
        return [
          {'error': 'Failed to fetch fees'}
        ];
      }
    } catch (e) {
      return [
        {'error': 'An error occurred while fetching fees: ${e.toString()}'}
      ];
    }
  }
}
