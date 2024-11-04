import 'dart:async';
import 'dart:developer';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';

class ServerResponseInterceptor implements InterceptorContract {
  static final _serverErrorStatusCodes = [
    500,
    501,
    502,
    503,
    504,
    505,
    504,
    506,
    507,
    508,
    509,
    510,
    511
  ];
  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    log(request.headers.toString());
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    if (_serverErrorStatusCodes.contains(response.statusCode)) {
      log(response.request.toString());
      throw ServerException('Oops! Something went wrong.', response.statusCode);
    }
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}
