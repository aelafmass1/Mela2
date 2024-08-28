import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_mobile_app/core/constants/Credentials.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlaidConfig {
 
  static const String env = 'sandbox';
  static const String clientName = 'Your App Name';
  

static String? secret = Credentials.plaid_sandbox;
static String? clientId = Credentials.Plaid_client;
}

class PlaidService {
  static Future<String?> createLinkToken() async {
    final response = await http.post(
      Uri.parse('https://${PlaidConfig.env}.plaid.com/link/token/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': PlaidConfig.clientId,
        'secret': PlaidConfig.secret,
        'user': {'client_user_id': 'unique_user_id'},
        'client_name': PlaidConfig.clientName,
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

  static Future<String?> exchangePublicToken(String publicToken) async {
    final response = await http.post(
      Uri.parse('https://${PlaidConfig.env}.plaid.com/item/public_token/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': PlaidConfig.clientId,
        'secret': PlaidConfig.secret,
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

class PlaidIntegration extends StatefulWidget {
  const PlaidIntegration({Key? key}) : super(key: key);

  @override
  _PlaidIntegrationState createState() => _PlaidIntegrationState();
}

class _PlaidIntegrationState extends State<PlaidIntegration> {
  String? _linkToken;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializePlaid();
  }

  Future<void> _initializePlaid() async {
    try {
      final linkToken = await PlaidService.createLinkToken();
      setState(() => _linkToken = linkToken);
    } catch (e) {
      _showErrorDialog('Failed to initialize Plaid: $e');
    }
  }

  Future<void> _onPlaidSuccess(String publicToken) async {
    try {
      final accessToken = await PlaidService.exchangePublicToken(publicToken);
      setState(() => _accessToken = accessToken);
      print('Access Token: $_accessToken');
    } catch (e) {
      _showErrorDialog('Failed to exchange public token: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaid Integration')),
      body: Center(
        child: _linkToken == null
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _openPlaidWebView(),
                child: const Text('Connect Bank Account'),
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

  const PlaidWebView({
    Key? key,
    required this.linkToken,
    required this.onSuccess,
  }) : super(key: key);

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