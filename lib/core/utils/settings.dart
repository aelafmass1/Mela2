import 'package:shared_preferences/shared_preferences.dart';

const _isFirstTimeKey = 'isFirstTime';
const _isContactPermissonAllowed = '_isContactPermissonAllowed';

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
