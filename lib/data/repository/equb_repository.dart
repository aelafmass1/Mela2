import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';

import '../models/contact_model.dart';

class EqubRepository {
  final Dio client;

  EqubRepository({required this.client});

  Future<Map> createEqub(EqubModel equb, String currencyCode) async {
    final body = {
      "name": equb.name,
      "numberOfMembers": equb.numberOfMembers,
      "contributionAmount": equb.contributionAmount.toInt(),
      "frequency": equb.frequency,
      "currency": currencyCode.trim(),
      "startDate":
          "${equb.startDate.year}-${equb.startDate.month.toString().padLeft(2, '0')}-${equb.startDate.day.toString().padLeft(2, '0')}"
    };
    final res = await client.post(
      '/ekub/create',
      data: body,
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return processErrorResponse(data);
  }

  Future<List> inviteMembers(
      {required int equbId, required List<ContactModel> members}) async {
    final body = members.map((m) => m.toMap()).toList();
    final res = await client.post(
      '/ekub/$equbId/invite',
      data: body,
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data['successResponse'];
    }
    return [processErrorResponse(data)];
  }

  Future<List> fetchEqubs() async {
    final res = await client.get('/ekub/all');

    final data = res.data;
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
    required int equbId,
  }) async {
    final res = await client.get('/ekub/$equbId/get');

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data['successResponse'];
    }

    return processErrorResponse(data);
  }

  Future<List> fetchEqubMembers({
    required int equbId,
  }) async {
    final res = await client.get('/ekub/$equbId/members/get');

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 204) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  Future<Map> manualAssignWinner({
    required int cycleId,
    required int memberId,
  }) async {
    final res = await client
        .post('/ekub/cycles/$cycleId/assign-winner?memberId=$memberId');

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data['successResponse'];
    }
    return processErrorResponse(data);
  }

  Future<Map> autoPickWinner({
    required int cycleId,
  }) async {
    final res = await client.post(
      '/ekub/winner/autoPicker?cycleId=$cycleId',
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data['successResponse'];
    }
    return processErrorResponse(data);
  }

  Future<Map> fetchEqubCurrencies() async {
    final res = await client.get('/ekub/currency/all');
    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return processErrorResponse(data);
  }
}
