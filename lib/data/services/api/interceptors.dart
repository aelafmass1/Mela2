import 'package:dio/dio.dart';

import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/services/api/api_service.dart';
import 'package:transaction_mobile_app/data/services/api/retry_helper.dart';

class DioInterceptor extends Interceptor {
  DioInterceptor();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final authToken = await getToken();
    if (authToken != null) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ),
      );
    } else {
      // Use ErrorMapper to log or transform errors

      // Optionally retry the request
      if (_shouldRetry(err)) {
        try {
          final response =
              await RetryHelper.retry(() => _retryRequest(err.requestOptions));
          handler.resolve(response);
        } catch (retryError) {
          handler.next(err); // Retry failed; pass the original error
        }
      } else {
        handler.next(err); // Pass the error if no retry
      }
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = ApiService().client; // Reuse the existing Dio instance

    final authToken = await getToken();
    if (authToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $authToken';
    }

    return dio.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}
