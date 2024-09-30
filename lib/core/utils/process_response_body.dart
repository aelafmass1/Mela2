Map<String, dynamic> processErrorResponse(dynamic data) {
  if (data is Map) {
    if (data.containsKey('error')) {
      return {'error': data['error']};
    } else if (data.containsKey('message')) {
      return {'error': data['message']};
    }
  } else if (data is String) {
    return {"error": data};
  }
  // Handle other types if needed, returning an error
  return {"error": data};
}
