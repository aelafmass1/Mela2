import 'dart:convert';

import 'package:http/http.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';

import '../../core/exceptions/server_exception.dart';
import '../models/contact_model.dart';

class EqubRepository {
  final Client client;

  EqubRepository({required this.client});

  Future<Map> createEqub(EqubModel equb, String accessToken) async {
    final body = {
      "name": equb.name,
      "numberOfMembers": equb.numberOfMembers,
      "contributionAmount": equb.contributionAmount.toInt(),
      "frequency": equb.frequency,
      "startDate":
          "${equb.startDate.year}-${equb.startDate.month.toString().padLeft(2, '0')}-${equb.startDate.day.toString().padLeft(2, '0')}"
    };
    final res = await client.post(
      Uri.parse('$baseUrl/ekub/create'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<List> inviteMembers(
      {required int equbId,
      required String accessToken,
      required List<ContactModel> members}) async {
    final body = members.map((m) => m.toMap()).toList();
    final res = await client.post(
      Uri.parse('$baseUrl/ekub/$equbId/invite'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data['successResponse'];
    }
    return [processErrorResponse(data)];
  }

  Future<List> fetchEqubs({
    required String accessToken,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl/ekub/all'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data['successResponse'];
    }
    if (data.containsKey('errorResponse')) {
      return [
        {'error': data['errorResponse']['message']}
      ];
    }
    if (data.containsKey('error')) {
      return [
        {'error': data['error']}
      ];
    }
    return [processErrorResponse(data)];
  }

  Future<Map> fetchEqubDetail({
    required String accessToken,
    required int equbId,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl/ekub/$equbId/get'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data['successResponse'];
    }

    return processErrorResponse(data);
  }

  Future<List> fetchEqubMembers({
    required String accessToken,
    required int equbId,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl/ekub/$equbId/members/get'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  Future<Map> manualAssignWinner({
    required String accessToken,
    required int cycleId,
    required int memberId,
  }) async {
    final res = await client.post(
      Uri.parse(
          '$baseUrl/ekub/cycles/$cycleId/assign-winner?memberId=$memberId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data['successResponse'];
    }
    return processErrorResponse(data);
  }

  Future<Map> autoPickWinner({
    required String accessToken,
    required int cycleId,
  }) async {
    final res = await client.post(
      Uri.parse('$baseUrl/ekub/winner/autoPicker?cycleId=$cycleId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 500) {
      throw ServerException('Internal Server Error');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data['successResponse'];
    }
    return processErrorResponse(data);
  }
}
