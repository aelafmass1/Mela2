import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class CurrencyRepository {
  final Dio client;

  CurrencyRepository({required this.client});
  Future<Map<String, dynamic>> fetchPromotionalCurrency() async {
    final res = await client.get(
      '/api/exchange-rates',
      // headers: {
      //   'Authorization': 'Bearer $accessToken',
      //   'Content-Type': 'application/json',
      //   'currencyCode': 'USD',
      // },
    );

    final data = res.data as List;
    if (res.statusCode == 200) {
      return data.first;
    }
    return processErrorResponse(data);
  }

  Future<List> fetchCurrencies() async {
    final res = await client.get(
      '/api/exchange-rates',
      // ),
      // headers: {
      //   'Authorization': 'Bearer $accessToken',
      //   'Content-Type': 'application/json',
      //   'currencyCode': '',
      // },
    );

    final data = res.data as List;
    if (res.statusCode == 200) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
