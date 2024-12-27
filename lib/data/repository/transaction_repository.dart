import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class TransactionRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  TransactionRepository({required this.client, required this.errorHandler});
  Future<Map<String, dynamic>> fetchTransaction() async {
    return await errorHandler.withErrorHandler<Map<String, dynamic>>(() async {
      final res = await client.get(
        '/api/v1/money-transfer/transactions',
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        List data = [];
        if (res.data.isNotEmpty) {
          data = res.data;
        } else {
          data = [];
        }
        return {'success': data};
      }
      return processErrorResponse(res.data);
    });
  }
}
