import 'package:flutter_dotenv/flutter_dotenv.dart';

class Credentials {
  static String? baseUrl = dotenv.env['REST_END_POINT'];
  static String? plaid_sandbox = dotenv.env['PLAID_SANDBOX_ID'];
  static String? Plaid_client = dotenv.env['PLAID_CLIENT_ID'];
}
