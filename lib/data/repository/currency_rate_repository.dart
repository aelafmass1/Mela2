import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class CurrencyRateRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  CurrencyRateRepository({required this.client, required this.errorHandler});
  Future<List> fetchCurrencyRate() async {
    return await errorHandler.withErrorHandler<List>(() async {
      final res = await client.get(
        '/currency/latest',
      );

      if (res.statusCode == 200) {
        final data = res.data;
        List rates = data[0]['rates'];
        return rates;
      }
      throw Exception('Failed to fetch currency rate');
    });
  }
}
