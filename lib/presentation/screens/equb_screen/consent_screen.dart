import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../gen/colors.gen.dart';
import '../../widgets/text_widget.dart';

class ConsentScreen extends StatefulWidget {
  final Function(bool isValid) result;
  const ConsentScreen({super.key, required this.result});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool isAgreed = false;
  bool isWebviewLoading = false;

  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isWebviewLoading = false;
              });
            } else {
              setState(() {
                isWebviewLoading = true;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://static.melafinance.com/TOS.html'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.result(isAgreed);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          leading: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: IconButton(
              onPressed: () {
                isAgreed = false;
                context.pop();
              },
              icon: const Icon(
                Icons.close,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(text: 'Consent'),
              const SizedBox(
                height: 20,
              ),
              _buildTermAndCondition(),
              ButtonWidget(
                onPressed: isAgreed
                    ? () {
                        context.pop();
                      }
                    : null,
                child: const TextWidget(
                  text: 'Next',
                  type: TextType.small,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  _buildTermAndCondition() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.sw,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(-2, -2),
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isWebviewLoading
                  ? const Center(child: LoadingWidget())
                  : WebViewWidget(controller: controller),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                  shape: const CircleBorder(),
                  activeColor: ColorName.primaryColor,
                  value: isAgreed,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        isAgreed = value;
                      });
                    }
                  }),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isAgreed = !isAgreed;
                  });
                },
                child: const TextWidget(
                  text: 'Yes, I agree to the terms and Conditions.',
                  type: TextType.small,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
