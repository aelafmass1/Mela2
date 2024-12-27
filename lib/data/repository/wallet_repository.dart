import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/data/services/error_helper.dart';
import '../../core/utils/process_error_response_.dart';
import '../models/transfer_rate_model.dart';

class WalletRepository {
  final Dio client;
  final IErrorHandler errorHandler;
  WalletRepository({required this.client, required this.errorHandler});

  Future<Map> fetchWallets() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get(
        '/api/wallet/all',
      );
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> createWallet({required String currency}) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.post(
        '/api/wallet/create/$currency',
      );

      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> fetchWalletCurrencies() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get('/api/wallet/currency/all');
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return {'data': data};
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> addFundToWallet({
    required num amount,
    required String paymentType,
    required String publicToken,
    required String savedPaymentId,
    required int walletId,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.post('/api/wallet/top-up', data: {
        "amount": amount.toInt(),
        "paymentType": paymentType,
        "savedPaymentId": savedPaymentId,
        "walletId": walletId,
      });
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<TransferRateModel> fetchTransferRate({
    required int fromWalletId,
    required int toWalletId,
    required num amount,
  }) async {
    return await errorHandler.withErrorHandler<TransferRateModel>(() async {
      try {
        final res = await client.get(
          '/api/wallet/transfer/rate',
          queryParameters: {
            "fromWalletId": fromWalletId.toString(),
            "toWalletId": toWalletId.toString(),
          },
        );
        final data = res.data;
        if (res.statusCode == 200 || res.statusCode == 204) {
          final successResponse = data['successResponse'];
          return TransferRateModel.fromJson(successResponse);
        }
        return processErrorResponse(data)['message'];
      } catch (e) {
        throw e.toString();
      }
    });
  }

  Future<Map> fetchTransferFeesForUnregisteredUser({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get(
        '/api/wallet/transfer/fees/by-currency',
        queryParameters: {
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
        },
      );
      final data = res.data;

      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> fetchTransferFees({
    required int fromWalletId,
    required int toWalletId,
  }) async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get(
        '/api/wallet/transfer/fees',
        queryParameters: {
          "fromWalletId": fromWalletId.toString(),
          "toWalletId": toWalletId.toString(),
        },
      );
      final data = res.data;

      if (res.statusCode == 200 || res.statusCode == 204) {
        return data;
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> fetchWalletTransaction() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get('/api/wallet/transactions');
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return {'data': data};
      }
      return processErrorResponse(data);
    });
  }

  Future<Map> fetchRecentWalletTransactions() async {
    return await errorHandler.withErrorHandler<Map>(() async {
      final res = await client.get('/api/wallet/recent-recipients');
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 204) {
        return {'data': data};
      }
      return processErrorResponse(data);
    });
  }
}
