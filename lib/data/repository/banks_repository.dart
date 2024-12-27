import 'dart:convert';

import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

class BanksRepository {
  final InterceptedClient client;
  BanksRepository({required this.client});

  Future<List> fetchBanks(String accessToken) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/v1/banks',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(res.body) as List;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  Future<List> fetchBankFee(String accessToken) async {
    final res = await client.get(
      Uri.parse(
        '$baseUrl/api/fees/payment-method/all',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }
}
