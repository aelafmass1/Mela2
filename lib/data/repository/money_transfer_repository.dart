import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';

class MoneyTransferRepository {
  final InterceptedClient client;

  MoneyTransferRepository({required this.client});

  /// Sends money to a receiver using the provided information.
  ///
  /// [accessToken] is the authentication token required to make the request.
  /// [receiverInfo] contains the details of the receiver, including their name, phone number, bank name, account number, amount, service charge payer, and payment type.
  /// [paymentId] is the ID of the payment intent.
  /// [savedPaymentId] is the ID of the saved payment method.
  ///
  /// Returns a map with either a 'success' key containing the response data, or an 'error' key containing an error message.
  Future<Map> sendMoney({
    required String accessToken,
    required ReceiverInfo receiverInfo,
    required String paymentId,
    required String savedPaymentId,
  }) async {
    final res = await client.post(
      Uri.parse(
        '$baseUrl/api/v1/money-transfer/send',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "receiverName": receiverInfo.receiverName,
        "receiverPhoneNumber": receiverInfo.receiverPhoneNumber,
        "receiverBankName": receiverInfo.receiverBankName,
        "receiverAccountNumber": receiverInfo.receiverAccountNumber,
        "amount": receiverInfo.amount,
        "serviceChargePayer": receiverInfo.serviceChargePayer,
        "paymentType": receiverInfo.paymentType,
        "publicToken": receiverInfo.publicToken ?? '',
        "paymentIntentId": paymentId,
        "savedPaymentId": savedPaymentId,
      }),
    );

    String data = res.body;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': data};
    }
    return processErrorResponse(data);
  }

  /// Transfers money between own wallets
  ///
  /// [accessToken] is the authentication token required to make the request.
  /// [fromWalletId] is the ID of the source wallet
  /// [toWalletId] is the ID of the destination wallet
  /// [amount] is the amount to transfer
  ///
  /// Returns a map with either a 'success' key containing the response data, or an 'error' key containing an error message.
  Future<Map> transferToOwnWallet({
    required String accessToken,
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    required String note,
  }) async {
    final res = await client.post(
      Uri.parse(
        '$baseUrl/api/wallet/transfer',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "fromWalletId": fromWalletId,
        "toWalletId": toWalletId,
        "amount": amount,
        "note": note,
      }),
    );

    String data = res.body;
    if (res.statusCode == 200 || res.statusCode == 201) {
      final decodedData = jsonDecode(data);
      return {'success': decodedData};
    }
    return processErrorResponse(data);
  }
}
