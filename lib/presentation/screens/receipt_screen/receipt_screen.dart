import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/receipt_page.dart';

class ReceiptScreen extends StatelessWidget {
  final ReceiverInfo receiverInfo;
  const ReceiptScreen({super.key, required this.receiverInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 28,
      ),
      body: Align(
          alignment: Alignment.topCenter,
          child: ReceiptPage(receiverInfo: receiverInfo)),
    );
  }
}
