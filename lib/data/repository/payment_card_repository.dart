import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class PaymentCardRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  PaymentCardRepository({required this.client, required this.errorHandler});

  /// Adds a new payment card to the user's account.
  ///
  /// This method sends a POST request to the `/payment-methods/add-card` endpoint
  /// with the provided `accessToken` in the `Authorization` header and the `token` parameter
  /// in the request body. If the request is successful (status code 200 or 201), the method
  /// returns the decoded JSON response data. If the request returns a 500 status code, the
  /// method returns an error map with the message 'Internal Server Error'. Otherwise, it
  /// returns the error response processed by the `processErrorResponse` function.
  ///
  /// Parameters:
  /// - `accessToken`: The access token required to authenticate the request.
  /// - `token`: The token representing the payment card to be added.
  ///
  /// Returns:
  /// A `Future<Map<String, dynamic>>` containing the payment card data or an error response.
  Future<Map> addPaymentCard({
    required String token,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.post(
        '/payment-methods/add-card',
        data: {
          "token": token,
        },
      );

      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> addBankAccount(String publicToken) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.post(
        '/payment-methods/add-bank-account',
        data: {
          "publicToken": publicToken,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return res.data as Map<String, dynamic>;
      }
      return processErrorResponse(res.data);
    });
  }

  /// Fetches a list of payment cards associated with the provided access token.
  ///
  /// This method sends a GET request to the `/payment-methods/list` endpoint
  /// with the provided `accessToken` in the `Authorization` header. If the request
  /// is successful (status code 200 or 201), the method returns the decoded JSON
  /// response data. Otherwise, it returns a list containing the error response
  /// processed by the `processErrorResponse` function.
  ///
  /// Parameters:
  /// - `accessToken`: The access token required to authenticate the request.
  ///
  /// Returns:
  /// A `Future<List>` containing the payment card data or an error response.
  Future<List> fetchPaymentCards() async {
    return await errorHandler.withErrorHandler<List>(() async {
      final res = await client.get('/payment-methods/list');

      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      }
      return [processErrorResponse(data)];
    });
  }
}
