import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/Credentials.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeACHPayment extends StatefulWidget {
  @override
  _StripeACHPaymentState createState() => _StripeACHPaymentState();
}

class _StripeACHPaymentState extends State<StripeACHPayment> {
  final String plaidPublicKey = 'your_plaid_public_key';
  //final String plaidClientId = 'your_plaid_client_id';
  //final String plaidSecret = 'your_plaid_secret';
  final String stripeSecretKey = 'your_stripe_secret_key';

    static const String env = 'sandbox';
  static const String clientName = 'Your App Name';
  

static String? plaidSecret = Credentials.plaid_sandbox;
static String? plaidClientId = Credentials.Plaid_client;

  String? publicToken;
  String? accountId;

  Future<void> initializePlaidLink() async {
    final response = await http.post(
      Uri.parse('https://sandbox.plaid.com/link/token/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': plaidClientId,
        'secret': plaidSecret,
        'user': {'client_user_id': 'unique_user_id'},
        'client_name': 'Your App Name',
        'products': ['auth'],
        'country_codes': ['US'],
        'language': 'en',
      }),
    );

    if (response.statusCode == 200) {
      final linkToken = jsonDecode(response.body)['link_token'];
      _openPlaidLinkWebView(linkToken);
    } else {
      print('Failed to create Plaid link token');
    }
  }

  void _openPlaidLinkWebView(String linkToken) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Link your bank account')),
          body: WebView(
            initialUrl: 'https://cdn.plaid.com/link/v2/stable/link.html?token=$linkToken',
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('plaidlink://')) {
                final uri = Uri.parse(request.url);
                final params = uri.queryParameters;
                publicToken = params['public_token'];
                accountId = params['account_id'];
                _exchangePublicToken();
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _exchangePublicToken() async {
    final response = await http.post(
      Uri.parse('https://sandbox.plaid.com/item/public_token/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': plaidClientId,
        'secret': plaidSecret,
        'public_token': publicToken,
      }),
    );

    if (response.statusCode == 200) {
      final accessToken = jsonDecode(response.body)['access_token'];
      _createStripeBankToken(accessToken);
    } else {
      print('Failed to exchange public token');
    }
  }

  Future<void> _createStripeBankToken(String plaidAccessToken) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/tokens'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'bank_account[account_holder_name]': 'John Doe',
        'bank_account[account_holder_type]': 'individual',
        'bank_account[country]': 'US',
        'bank_account[currency]': 'usd',
        'bank_account[routing_number]': '110000000',
        'bank_account[account_number]': '000123456789',
      },
    );

    if (response.statusCode == 200) {
      final bankAccountToken = jsonDecode(response.body)['id'];
      _createStripeCustomer(bankAccountToken);
    } else {
      print('Failed to create Stripe bank token');
    }
  }

  Future<void> _createStripeCustomer(String bankAccountToken) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'source': bankAccountToken,
        'email': 'customer@example.com',
      },
    );

    if (response.statusCode == 200) {
      final customerId = jsonDecode(response.body)['id'];
      print('Stripe customer created: $customerId');
      // You can now use this customerId to create charges or setup recurring payments
    } else {
      print('Failed to create Stripe customer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stripe ACH Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: initializePlaidLink,
          child: Text('Link Bank Account'),
        ),
      ),
    );
  }
}