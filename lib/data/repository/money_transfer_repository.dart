import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';

class MoneyTransferRepository {
  static Future<Map> sendMoney({
    required String accessToken,
    required ReceiverInfo receiverInfo,
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
        "senderUserId": receiverInfo.senderUserId,
        "receiverName": receiverInfo.receiverName,
        "receiverPhoneNumber": receiverInfo.receiverPhoneNumber,
        "receiverBankName": receiverInfo.receiverBankName,
        "receiverAccountNumber": receiverInfo.receiverAccountNumber,
        "amount": receiverInfo.amount,
        "serviceChargePayer": receiverInfo.serviceChargePayer,
      }),
    );

    String data = res.body;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': data};
    }
    return {'error': data};
  }
}
