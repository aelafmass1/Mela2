import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class TransactionRepository {
  final Dio client;

  TransactionRepository({required this.client});
  Future<Map<String, dynamic>> fetchTransaction() async {
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
  }
}
