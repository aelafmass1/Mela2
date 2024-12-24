import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:transaction_mobile_app/core/exceptions/no_internet_exception.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';
import 'package:transaction_mobile_app/core/utils/check_connectivity.dart';

class ConnectivityInterceptor implements InterceptorContract {
  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (await checkConnectivity() == false) {
      throw ServerException('No Internet Connection', 0);
    }
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() async {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}
