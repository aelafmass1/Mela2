import 'dart:convert';
import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:transaction_mobile_app/data/repository/equb_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late EqubRepository equbRepository;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    equbRepository = EqubRepository(client: mockClient);
  });

  group('EcubRepository', () {
    var tEqubModel = EqubModel(
      contributionAmount: 100,
      frequency: 'WEEKLY',
      numberOfMembers: 10,
      name: 'Test Equb',
      startDate: DateTime.parse('2024-09-20'),
      members: [],
    );

    const tEqubJson = {
      'name': 'Test Equb',
      'numberOfMembers': 10,
      'contributionAmount': 100.0,
      'frequency': 'WEEKLY',
      'startDate': '2024-9-20'
    };

    group('createEqub', () {
      test(
        'should return EqubModel when the response code is 201 (Created)',
        () async {
          // arrange
          when(() =>
              mockClient.post(Uri.parse('$baseUrl/ekub/create'),
                  headers: any(named: 'headers'),
                  body: any(named: 'body'))).thenAnswer(
              (_) async => http.Response(json.encode(tEqubJson), 200, headers: {
                    'Content-Type': 'application/json',
                  }));
          // act
          final result = await equbRepository.createEqub(tEqubModel, 'token');
          // assert
          expect(result, equals(tEqubModel.toMap()));
        },
      );
      test(
        'should return a ServerFailure when the response code is 400 or 500',
        () async {
          // arrange
          when(() => mockClient.post(Uri.parse('$baseUrl/ekub/create'),
              headers: any(named: 'headers'),
              body: any(named: 'body'))).thenAnswer((_) async => http.Response(
                  json.encode({
                    "errorResponse": {"message": "Server Error"}
                  }),
                  400,
                  headers: {
                    'Content-Type': 'application/json',
                  }));
          // act
          final result = await equbRepository.createEqub(tEqubModel, 'token');
          log(result.toString());
          // assert
          expect(result, {'error': "Server Error"});
        },
      );
    });

    group('getAllEqubs', () {
      test(
        'should return List<EqubModel> when the response code is 200 (OK)',
        () async {
          // arrange
          when(() => mockClient.get(Uri.parse('$baseUrl/ekub/all'),
                  headers: any(named: 'headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode([tEqubJson]), 200,
                  headers: {'Content-Type': 'application/json'}));
          // act
          final result = await equbRepository.fetchEqubs(accessToken: 'token');
          // assert
          expect(result, [tEqubModel.toMap()]);
        },
      );

      test(
        'should return a ServerFailure when the response code is 400 or 500',
        () async {
          // arrange
          when(() => mockClient.get(Uri.parse('$baseUrl/ekub/all'),
                  headers: any(named: 'headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    "errorResponse": {"message": "Server Error"}
                  }),
                  400));
          // act
          final result = await equbRepository.fetchEqubs(accessToken: 'token');
          // assert
          expect(
            result,
            [
              {'error': "Server Error"}
            ],
          );
        },
      );
    });

    group('invite members', () {
      test(
        'should return a List when the response code is 201 ',
        () async {
          // arrange
          when(() => mockClient.post(Uri.parse('$baseUrl/ekub/1/invite'),
                  headers: any(named: 'headers'), body: any(named: 'body')))
              .thenAnswer((_) async =>
                  http.Response(json.encode([tEqubJson]), 200, headers: {
                    'Content-Type': 'application/json',
                  }));
          // act
          final result = await equbRepository.inviteMembers(
            accessToken: 'token',
            equbId: 1,
            members: [],
          );
          // assert
          expect(result, equals([tEqubModel.toMap()]));
        },
      );
      test(
        'should return a List with error when the response code is 400 | 500 ',
        () async {
          // arrange
          when(() => mockClient.post(Uri.parse('$baseUrl/ekub/1/invite'),
              headers: any(named: 'headers'),
              body: any(named: 'body'))).thenAnswer((_) async => http.Response(
                  json.encode([
                    {'error': "something is wrong"}
                  ]),
                  200,
                  headers: {
                    'Content-Type': 'application/json',
                  }));
          // act
          final result = await equbRepository.inviteMembers(
            accessToken: 'token',
            equbId: 1,
            members: [],
          );
          log(result.toString());
          // assert
          expect(result.first.containsKey('error'), true);
        },
      );
    });
  });
}
