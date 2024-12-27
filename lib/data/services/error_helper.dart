import 'package:dio/dio.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

abstract class IErrorHandler {
  Future<T> withErrorHandler<T>(fn);
}

class ErrorHandler extends IErrorHandler {
  @override
  Future<T> withErrorHandler<T>(fn) async {
    try {
      return await fn();
    } on DioException catch (error, _) {
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final errorMessage = processErrorResponse(data)["error"];
        throw ServerException(errorMessage, statusCode ?? 0);
      }
      throw ServerException("Ops something went wrong", 500);
    }
  }
}
