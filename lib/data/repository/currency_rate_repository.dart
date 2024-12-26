import 'package:dio/dio.dart';

class CurrencyRateRepository {
  final Dio client;

  CurrencyRateRepository({required this.client});
  Future<List> fetchCurrencyRate() async {
    // HttpMetric metric = FirebasePerformance.instance
    //     .newHttpMetric('/currency/latest', HttpMethod.Get);
    // metric.start();

    final res = await client.get(
      '/currency/latest',
    );

    if (res.statusCode == 200) {
      final data = res.data;
      List rates = data[0]['rates'];
      return rates;
    }
    throw Exception('Failed to fetch currency rate');
  }
}
