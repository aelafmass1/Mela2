import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class PlaidRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  PlaidRepository({required this.client, required this.errorHandler});

  Future<Map> createLinkToken() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get('/api/plaid/create-link-token');

      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      }
      return processErrorResponse(data);
    });
  }
}
