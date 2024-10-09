import 'package:http_interceptor/http_interceptor.dart';
import 'package:transaction_mobile_app/core/interceptors/server_response_interceptor.dart';

import '../../../core/interceptors/connectivity_interceptor.dart';

class ApiService {
  /// Creates an [InterceptedClient] with the [ConnectivityInterceptor] configured.
  ///
  /// The [InterceptedClient] is used to make HTTP requests with the specified interceptors.
  /// The [ConnectivityInterceptor] is used to handle connectivity-related issues, such as
  /// retrying requests when the device regains connectivity.
  final client = InterceptedClient.build(
    interceptors: [
      ConnectivityInterceptor(),
      ServerResponseInterceptor(),
    ],
  );
}
