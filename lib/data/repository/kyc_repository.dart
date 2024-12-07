import 'dart:convert';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

/// A repository class for interacting with Jumio KYC API.
class KycRepository {
  final InterceptedClient client;

  KycRepository({required this.client});

  /// Fetches the Jumio Authorization Token from the API.
  ///
  /// [jwt] is the JSON Web Token required for authentication.
  ///
  /// Returns a [Future] that completes with the authorization token as a [String].
  /// If there's an error, it returns a map containing the error details.
  Future<dynamic> fetchAuthorizationToken(String jwt) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/kyc/sdk-token'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['successResponse'] != null) {
        return data['successResponse'];
      } else {
        return processErrorResponse({
          'message': data['message'] ?? 'Unknown error',
          'errorResponse': data['errorResponse'] ?? {},
        });
      }
    } catch (e) {
      return processErrorResponse({'message': 'An unexpected error occurred'});
    }
  }
}
