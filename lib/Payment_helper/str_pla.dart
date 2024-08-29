import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/Credentials.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';

class Config {
  //static const String plaidClientId = 'YOUR_PLAID_CLIENT_ID';
  static const String plaidSecret = 'YOUR_PLAID_SECRET';
  static const String plaidEnv = 'sandbox'; // Use 'development' or 'production' for live environments
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String backendUrl = 'YOUR_BACKEND_URL'; // Your server endpoint

  static const String env = 'sandbox';
  static const String clientName = 'Your App Name';
  

static String? secret = Credentials.plaid_sandbox;
static String? plaidClientId = Credentials.Plaid_client;
}

class PlaidStripeIntegration extends StatefulWidget {
  @override
  _PlaidStripeIntegrationState createState() => _PlaidStripeIntegrationState();
}

class _PlaidStripeIntegrationState extends State<PlaidStripeIntegration> {
  String? _linkToken;
  String? _accessToken;
  String? _stripeBankAccountToken;

  @override
  void initState() {
    super.initState();
    _initializePlaid();
    _initializeStripe();
  }

  Future<void> _initializePlaid() async {
    try {
      final linkToken = await PlaidService.createLinkToken();
      setState(() => _linkToken = linkToken);
    } catch (e) {
      _showErrorDialog('Failed to initialize Plaid: $e');
    }
  }

  void _initializeStripe() {
    Stripe.publishableKey = Config.stripePublishableKey;
  }

  Future<void> _onPlaidSuccess(String publicToken) async {
    try {
      // Exchange public token for access token
      _accessToken = await PlaidService.exchangePublicToken(publicToken);
      
      // Get bank account token from your backend
      _stripeBankAccountToken = await _getStripeBankAccountToken(_accessToken!);
      
      // Now you can use _stripeBankAccountToken to create a payment method or charge in Stripe
      print('Stripe Bank Account Token: $_stripeBankAccountToken');
      
      // Optionally, create a payment method or initiate a charge here
    } catch (e) {
      _showErrorDialog('Failed to process Plaid token: $e');
    }
  }

  Future<String> _getStripeBankAccountToken(String plaidAccessToken) async {
    final response = await http.post(
      Uri.parse('${Config.backendUrl}/create-stripe-bank-account-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plaid_access_token': plaidAccessToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['stripe_bank_account_token'];
    } else {
      throw Exception('Failed to get Stripe bank account token: ${response.body}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plaid-Stripe Integration')),
      body: Center(
        child: _linkToken == null
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _openPlaidWebView(),
                child: Text('Connect Bank Account'),
              ),
      ),
    );
  }

  void _openPlaidWebView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaidWebView(
          linkToken: _linkToken!,
          onSuccess: _onPlaidSuccess,
        ),
      ),
    );
  }
}

class PlaidWebView extends StatelessWidget {
  final String linkToken;
  final Function(String) onSuccess;

  const PlaidWebView({Key? key, required this.linkToken, required this.onSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://cdn.plaid.com/link/v2/stable/link.html?token=$linkToken',
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (request) => _handleNavigation(context, request),
    );
  }

  NavigationDecision _handleNavigation(BuildContext context, NavigationRequest request) {
    if (request.url.startsWith('plaidlink://')) {
      final uri = Uri.parse(request.url);
      final publicToken = uri.queryParameters['public_token'];
      if (publicToken != null) {
        onSuccess(publicToken);
        Navigator.pop(context);
      }
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }
}

class PlaidService {
  static Future<String> createLinkToken() async {
    final response = await http.post(
      Uri.parse('https://${Config.plaidEnv}.plaid.com/link/token/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': Config.plaidClientId,
        'secret': Config.plaidSecret,
        'user': {'client_user_id': 'unique_user_id'},
        'client_name': 'Your App Name',
        'products': ['auth'],
        'country_codes': ['US'],
        'language': 'en',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['link_token'];
    } else {
      throw Exception('Failed to create link token: ${response.body}');
    }
  }

  static Future<String> exchangePublicToken(String publicToken) async {
    final response = await http.post(
      Uri.parse('https://${Config.plaidEnv}.plaid.com/item/public_token/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': Config.plaidClientId,
        'secret': Config.plaidSecret,
        'public_token': publicToken,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Failed to exchange public token: ${response.body}');
    }
  }
}