import 'package:flutter_test/flutter_test.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

void main() {
  group('processErrorResponse', () {
    test('should return error map when input is a map with error key', () {
      final result = processErrorResponse({'error': 'Test error'});
      expect(result, {'error': 'Test error'});
    });

    test('should return error map when input is a map with message key', () {
      final result = processErrorResponse({'message': 'Test message'});
      expect(result, {'error': 'Test message'});
    });

    test(
        'should return error map when input is a map with errorResponse key containing message',
        () {
      final result = processErrorResponse({
        'errorResponse': {'message': 'Error message'}
      });
      expect(result, {'error': 'Error message'});
    });

    test(
        'should return error map when input is a map with errorResponse key without message',
        () {
      final result = processErrorResponse({'errorResponse': 'Error data'});
      expect(result, {'error': 'Error data'});
    });

    test('should process first item when input is a non-empty list', () {
      final result = processErrorResponse([
        {'error': 'List error'}
      ]);
      expect(result, {'error': 'List error'});
    });

    test('should return error map when input is a string', () {
      final result = processErrorResponse('String error');
      expect(result, {'error': 'String error'});
    });

    test('should return error map with input data for unhandled types', () {
      final result = processErrorResponse(42);
      expect(result, {'error': 42});
    });

    test('should return error map with empty list for empty list input', () {
      final result = processErrorResponse([]);
      expect(result, {'error': []});
    });
    test('should return the right error text from list', () {
      final result = processErrorResponse([
        {'error': 'List error'}
      ]);
      expect(result, {'error': 'List error'});
    });
  });
}
