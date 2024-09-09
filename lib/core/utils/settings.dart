import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _isFirstTimeKey = 'isFirstTime';
const _isContactPermissonAllowed = '_isContactPermissonAllowed';
const _jwtToken = 'jwt_token';
const _displayName = 'display_name';
const _imageUrl = 'image_url';
const _email = 'email';
const _phoneNumber = 'phone_number';

const storage = FlutterSecureStorage();

Future<bool> isFirstTime() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool(_isFirstTimeKey) ?? true;
}

Future<void> setFirstTime(bool isFirstTime) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(_isFirstTimeKey, isFirstTime);
}

Future<bool> isPermissionAsked() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool(_isContactPermissonAllowed) ?? false;
}

Future<void> changePermissionAskedState(bool isAllowed) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(_isContactPermissonAllowed, isAllowed);
}

Future<void> storeToken(String token) async {
  await storage.write(key: _jwtToken, value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: _jwtToken);
}

Future<void> deleteToken() async {
  await storage.delete(key: _jwtToken);
}

Future<void> storeDisplayName(String fullName) async {
  await storage.write(key: _displayName, value: fullName);
}

Future<String?> getDisplayName() async {
  return await storage.read(key: _displayName);
}

Future<void> deleteDisplayName() async {
  await storage.delete(key: _displayName);
}

Future<void> storeImageUrl(String fullName) async {
  await storage.write(key: _imageUrl, value: fullName);
}

Future<String?> getImageUrl() async {
  return await storage.read(key: _imageUrl);
}

Future<void> deleteImageUrl() async {
  await storage.delete(key: _imageUrl);
}

Future<void> storeEmail(String fullName) async {
  await storage.write(key: _email, value: fullName);
}

Future<String?> getEmail() async {
  return await storage.read(key: _email);
}

Future<void> deleteEmail() async {
  await storage.delete(key: _email);
}

Future<void> storePhoneNumber(String fullName) async {
  await storage.write(key: _phoneNumber, value: fullName);
}

Future<String?> getPhoneNumber() async {
  return await storage.read(key: _phoneNumber);
}

Future<void> deletePhoneNumber() async {
  await storage.delete(key: _phoneNumber);
}
