import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/models/fee_models.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late FeeRepository feeRepository;
  late MockHttpClient mockClient;
  setUp(() {
    mockClient = MockHttpClient();
    feeRepository = FeeRepository(client: mockClient);
  });
  group('FeeRepository', () {
    const tfeeJson = {
      'id': 12,
      'label': 'Test',
      'type': 'FIXED',
      'amount': 100,
    };
    final tFeeModel = FeeModel(
      id: 12,
      label: 'Test',
      type: 'FIXED',
      amount: 100,
    );

    test('should return a List of Fee when fetching is success', () async {
      // arrange
      when(() => mockClient.get(Uri.parse('$baseUrl/api/fees/all'),
              headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(json.encode([tfeeJson]), 200,
              headers: {'Content-Type': 'application/json'}));
      // act
      final result = await feeRepository.fetchFees('token');
      // assert
      expect(result, [tFeeModel.toMap()]);
    });
    test('should return a List of Fee when fetching is failed', () async {
      // arrange
      when(() => mockClient.get(Uri.parse('$baseUrl/api/fees/all'),
              headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
              json.encode([
                {'error': "Something went wrong"}
              ]),
              400,
              headers: {'Content-Type': 'application/json'}));
      // act
      final result = await feeRepository.fetchFees('token');
      // assert
      expect(result[0]['error'], "Failed to fetch fees");
    });
  });
}
