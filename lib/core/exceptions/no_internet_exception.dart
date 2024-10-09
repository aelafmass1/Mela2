// ignore_for_file: public_member_api_docs, sort_constructors_first
class NoInternetException implements Exception {
  final String message;

  NoInternetException({required this.message});

  @override
  String toString() => message;
}
