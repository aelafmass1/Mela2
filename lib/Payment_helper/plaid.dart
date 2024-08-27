

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PlaidIntegration extends StatefulWidget {
  @override
  _PlaidIntegrationState createState() => _PlaidIntegrationState();
}

class _PlaidIntegrationState extends State<PlaidIntegration> {
  final String clientId = '66c5fb0156db17001941cc19';
  final String secret = '3866ba2b1d60357194821add4a8b85';
  final String env = 'sandbox'; // Use 'development' or 'production' for live environments

  String? linkToken;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    createLinkToken();
  }

  Future<void> createLinkToken() async {
    final response = await http.post(
      Uri.parse('https://sandbox.plaid.com/link/token/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': clientId,
        'secret': secret,
        'user': {'client_user_id': 'unique_user_id'},
        'client_name': 'Your App Name',
        'products': ['auth'],
        'country_codes': ['US'],
        'language': 'en',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        linkToken = data['link_token'];
      });
    } else {
      print('Failed to create link token: ${response.body}');
    }
  }

  Future<void> exchangePublicToken(String publicToken) async {
    final response = await http.post(
      Uri.parse('https://$env.plaid.com/item/public_token/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': clientId,
        'secret': secret,
        'public_token': publicToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        accessToken = data['access_token'];
      });
      print('Access Token: $accessToken');
    } else {
      print('Failed to exchange public token: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaid Integration')),
      body: Center(
        child: linkToken == null
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaidWebView(
                        linkToken: linkToken!,
                        onSuccess: exchangePublicToken,
                      ),
                    ),
                  );
                },
                child: const Text('Connect Bank Account'),
              ),
      ),
    );
  }
}

class PlaidWebView extends StatelessWidget {
  final String linkToken;
  final Function(String) onSuccess;

  PlaidWebView({required this.linkToken, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://cdn.plaid.com/link/v2/stable/link.html?token=$linkToken',
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) {
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
      },
    );
  }
}