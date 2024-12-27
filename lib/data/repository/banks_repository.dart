import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class BanksRepository {
  final Dio client;
  final IErrorHandler errorHandler;
  BanksRepository({required this.client, required this.errorHandler});

  Future<List> fetchBanks() async {
    return await errorHandler.withErrorHandler<List>(() async {
      final res = await client.get('/api/v1/banks');

      final data = res.data as List;
      return data;
    });
  }

  Future<List> fetchBankFee() async {
    return await errorHandler.withErrorHandler<List>(() async {
      final res = await client.get('/api/fees/payment-method/all');

      final data = res.data;
      return data;
    });
  }
}
