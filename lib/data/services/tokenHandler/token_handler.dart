import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _jwtToken = 'jwt_token';

abstract class ITokenHandler {
  Future<void> storeToken(String token);
  Future<String?>? getToken();
  Future<void> deleteToken();
}

class TokenHandler extends ITokenHandler {
  final FlutterSecureStorage storage;
  TokenHandler({required this.storage});
  // Set the token
  @override
  Future<void> storeToken(String token) async {
    await storage.write(key: _jwtToken, value: token);
  }

  // Get the token
  @override
  Future<String?> getToken() async {
    return await storage.read(key: _jwtToken);
  }

  // Clear the token
  @override
  Future<void> deleteToken() async {
    await storage.delete(key: _jwtToken);
  }
}
