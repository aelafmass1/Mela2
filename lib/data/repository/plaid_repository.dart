import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class PlaidRepository {
  final Dio client;

  PlaidRepository({required this.client});

  Future<Map> createLinkToken() async {
    final res = await client.get('/api/plaid/create-link-token');

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }
}
