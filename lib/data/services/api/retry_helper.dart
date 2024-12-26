class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() request, {
    int retries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        return await request();
      } catch (e) {
        if (attempt == retries) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    throw Exception('Failed after $retries attempts');
  }
}
