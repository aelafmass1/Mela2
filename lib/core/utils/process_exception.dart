import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';

/// Processes an exception and returns a user-friendly error message.
///
/// This function takes an [exception] object and returns a string that represents
/// a user-friendly error message. If the [exception] is a [ClientException] or
/// a [SocketException], the function returns a generic "Connection Aborted"
/// message. Otherwise, it returns the string representation of the exception.
///
/// This function is intended to be used to handle exceptions that occur during
/// network requests or other I/O operations, and to provide a consistent error
/// message to the user.
String processException(Object exception) {
  if (exception is ClientException) {
    return 'Connection Aborted, Please check your internet connection';
  } else if (exception is SocketException) {
    return 'Connection Aborted, Please check your internet connection';
  }
  return exception.toString();
}
