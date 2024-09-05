import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/repository/fee_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('FeeRepository', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    test('fetchFees returns list of fees on successful API call', () async {
      when(mockHttpClient.get(Uri.parse('$baseUrl/api/fees/all'),
              headers: anyNamed('headers')))
          .thenAnswer(
        (_) async =>
            http.Response('[{"id": 1, "name": "Fee 1", "amount": 10.0}]', 200),
      );

      final result = await FeeRepository.fetchFees('dummy_token');

      expect(result, isA<List<dynamic>>());
      expect(result.length, 1);
      expect(result[0]['name'], 'Fee 1');
    });

    test('fetchFees returns error on non-200 status code', () async {
      when(mockHttpClient.get(Uri.parse('$baseUrl/api/fees/all'),
              headers: anyNamed('headers')))
          .thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      final result = await FeeRepository.fetchFees('dummy_token');

      expect(result, isA<List<dynamic>>());
      expect(result.length, 1);
      expect(result[0]['error'], contains('Failed to fetch fees'));
    });

    test('fetchFees returns error on exception', () async {
      when(mockHttpClient.get(Uri.parse('$baseUrl/api/fees/all'),
              headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      final result = await FeeRepository.fetchFees('dummy_token');

      expect(result, isA<List<dynamic>>());
      expect(result.length, 1);
      expect(result[0]['error'],
          contains('An error occurred while fetching fees'));
    });
  });
}
