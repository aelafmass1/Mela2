import 'dart:convert';

import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:http/http.dart' as http;

import '../models/contact_model.dart';

class EqubRepository {
  static Future<Map> createEqub(EqubModel equb, String accessToken) async {
    final body = {
      "name": equb.name,
      "numberOfMembers": equb.numberOfMembers,
      "contributionAmount": equb.contributionAmount.toInt(),
      "frequency": equb.frequency,
      "startDate":
          "${equb.startDate.year}-${equb.startDate.month.toString().padLeft(2, '0')}-${equb.startDate.day.toString().padLeft(2, '0')}"
    };
    final res = await http.post(
      Uri.parse('$baseUrl/ekub/create'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    if (data.containsKey('errorResponse')) {
      return {'error': data['errorResponse']['message']};
    }
    return {'error': res.body};
  }

  static Future<List> inviteMembers(
      {required int equbId,
      required String accessToken,
      required List<ContactModel> members}) async {
    final body = members.map((m) => m.toMap()).toList();
    final res = await http.post(
      Uri.parse('$baseUrl/ekub/$equbId/invite'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    if (data.containsKey('errorResponse')) {
      return [
        {'error': data['errorResponse']['message']}
      ];
    }
    return [
      {'error': res.body}
    ];
  }
}
