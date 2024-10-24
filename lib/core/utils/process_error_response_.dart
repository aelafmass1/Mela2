/// Processes an error response from an API or other data source, extracting the error message and returning it as a map.
///
/// This function takes a dynamic [data] object, which can be a [Map], [List], or [String], and attempts to extract the error message from it.
/// If the [data] is a [Map] and contains a 'error' or 'message' key, the function will return a map with the error message.
/// If the [data] is a [Map] and contains an 'errorResponse' key, the function will attempt to extract the error message from that.
/// If the [data] is a [List], the function will recursively process the first element of the list.
/// If the [data] is a [String], the function will return a map with the string as the error message.
/// If the [data] is of any other type, the function will return a map with the original [data] as the error message.
///
/// This function is useful for handling error responses from APIs or other data sources, where the error message may be nested in a complex data structure.
Map<String, dynamic> processErrorResponse(dynamic data) {
  if (data is Map) {
    if (data.containsKey('error')) {
      return {'error': data['error']};
    } else if (data.containsKey('message')) {
      return {'error': data['message']};
    } else if (data.containsKey('errorResponse')) {
      if (data['errorResponse'] is Map &&
          data['errorResponse'].containsKey('message')) {
        return {'error': data['errorResponse']['message']};
      }
      return {'error': data['errorResponse']};
    }
  } else if (data is List) {
    if (data.isNotEmpty) {
      return processErrorResponse(data.first);
    }
  } else if (data is String) {
    return {"error": data};
  }
  // Handle other types if needed, returning an error
  return {"error": data};
}
