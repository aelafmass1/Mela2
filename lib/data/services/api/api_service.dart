import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:transaction_mobile_app/core/constants/url_constants.dart';
import 'package:transaction_mobile_app/data/services/api/interceptors.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    final dioInterceptor =
        DioInterceptor(); // Pass SecureStorage to Interceptor

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: requestTimeOut),
      receiveTimeout: const Duration(seconds: responseTimeOut),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(dioInterceptor);
    // Add pretty logger interceptor
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  Dio get client => _dio;
}
