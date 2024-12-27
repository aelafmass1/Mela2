import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

/// A repository class for fetching fee data from an API.
class FeeRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  FeeRepository({required this.client, required this.errorHandler});

  /// Fetches a list of fees from the API.
  ///
  /// [accessToken] is the authentication token required for API access.
  ///
  /// Returns a [Future] that completes with a [List] of fee data.
  /// If the API call is successful, it returns the parsed fee data.
  /// If there's an error, it returns a list containing an error map.
  Future<List<dynamic>> fetchFees() async {
    return await errorHandler.withErrorHandler<List<dynamic>>(() async {
      final response = await client.get(
        '/api/fees/all',
      );

      final data = jsonDecode(response.data) as List<dynamic>;
      if (response.statusCode == 200) {
        return data;
      }
      return [processErrorResponse(jsonDecode(response.data))];
    });
  }

  Future<List> fetchRemittanceExchangeRate() async {
    return await errorHandler.withErrorHandler<List<dynamic>>(() async {
      final res = await client.get(
        '/api/exchange-rates/remittance/active',
      );
      final data = res.data;
      if (res.statusCode == 200) {
        return data;
      }
      return [processErrorResponse(data)];
    });
  }
}
