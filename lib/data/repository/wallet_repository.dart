import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';

import '../../core/constants/url_constants.dart';
import '../../core/utils/process_error_response_.dart';
import '../models/transfer_rate_model.dart';

class WalletRepository {
  final InterceptedClient client;

  WalletRepository({required this.client});

  Future<Map> fetchWallets({required String accessToken}) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/all',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> createWallet(
      {required String accessToken, required String currency}) async {
    final res = await client.post(
      Uri.parse(
        '$baseUrl/api/wallet/create/$currency',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchWalletCurrencies({required String accessToken}) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/currency/all',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return {'data': data};
    }
    return processErrorResponse(data);
  }

  Future<Map> addFundToWallet({
    required String accessToken,
    required num amount,
    required String paymentType,
    required String publicToken,
    required String savedPaymentId,
    required int walletId,
  }) async {
    final res = await client.post(
        Uri.parse(
          '$baseUrl/api/wallet/top-up',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "amount": amount.toInt(),
          "paymentType": paymentType,
          "savedPaymentId": savedPaymentId,
          "walletId": walletId,
        }));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<TransferRateModel> fetchTransferRate({
    required String accessToken,
    required int fromWalletId,
    required int toWalletId,
    required num amount,
  }) async {
    try {
      final res = await client.get(
        Uri.parse(
          '$baseUrl/api/wallet/transfer/rate',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        params: {
          "fromWalletId": fromWalletId.toString(),
          "toWalletId": toWalletId.toString(),
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 204) {
        final successResponse = data['successResponse'];
        return TransferRateModel.fromJson(successResponse);
      }
      return processErrorResponse(data)['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map> fetchTransferFeesForUnregisteredUser({
    required String accessToken,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/transfer/fees/by-currency',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      params: {
        "fromCurrency": fromCurrency,
        "toCurrency": toCurrency,
      },
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchTransferFees({
    required String accessToken,
    required int fromWalletId,
    required int toWalletId,
  }) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/transfer/fees',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      params: {
        "fromWalletId": fromWalletId.toString(),
        "toWalletId": toWalletId.toString(),
      },
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchWalletTransaction({required String accessToken}) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/transactions',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return {'data': data};
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchRecentWalletTransactions(
      {required String accessToken}) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/wallet/recent-recipients',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return {'data': data};
    }
    return processErrorResponse(data);
  }
}
