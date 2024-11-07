import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';

import '../../core/constants/url_constants.dart';
import '../../core/utils/process_error_response_.dart';

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
    required String paymentIntentId,
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
          "publicToken": publicToken,
          "paymentIntentId": paymentIntentId,
          "savedPaymentId": savedPaymentId,
          "walletId": walletId,
        }));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }
}
