import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class BanksRepository {
  final Dio client;
  BanksRepository({required this.client});

  Future<List> fetchBanks() async {
    final res = await client.get('/api/v1/banks');

    final data = res.data as List;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  Future<List> fetchBankFee() async {
    final res = await client.get('/api/fees/payment-method/all');

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
