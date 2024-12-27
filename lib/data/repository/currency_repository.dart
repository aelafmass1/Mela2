import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';

class CurrencyRepository {
  final Dio client;
  final IErrorHandler errorHandler;

  CurrencyRepository({required this.client, required this.errorHandler});
  Future<Map<String, dynamic>> fetchPromotionalCurrency() async {
    return await errorHandler.withErrorHandler<Map<String, dynamic>>(() async {
      final res = await client.get(
        '/api/exchange-rates',
        options: Options(
          headers: {
            ...client.options.headers,
            'currencyCode': 'USD',
          },
        ),
      );

      final data = res.data as List;
      if (res.statusCode == 200) {
        return data.first;
      }
      return processErrorResponse(data);
    });
  }

  Future<List> fetchCurrencies() async {
    return await errorHandler.withErrorHandler<List>(() async {
      final res = await client.get(
        '/api/exchange-rates',
      );

      final data = res.data as List;
      if (res.statusCode == 200) {
        return data;
      }
      return [processErrorResponse(data)];
    });
  }
}
