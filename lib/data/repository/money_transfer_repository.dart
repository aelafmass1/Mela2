import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';

class MoneyTransferRepository {
  /// Sends money to a receiver using the provided information.
  ///
  /// [accessToken] is the authentication token required to make the request.
  /// [receiverInfo] contains the details of the receiver, including their name, phone number, bank name, account number, amount, service charge payer, and payment type.
  /// [paymentId] is the ID of the payment intent.
  /// [savedPaymentId] is the ID of the saved payment method.
  ///
  /// Returns a map with either a 'success' key containing the response data, or an 'error' key containing an error message.
  static Future<Map> sendMoney({
    required String accessToken,
    required ReceiverInfo receiverInfo,
    required String paymentId,
    required String savedPaymentId,
  }) async {
    final res = await http.post(
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

    if (res.statusCode == 500) {
      return {'error': 'Internal Server Error'};
    }

    String data = res.body;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': data};
    }
    return processErrorResponse(data);
  }
}
