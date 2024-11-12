import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/presentation/widgets/qr_generator_widget.dart';

showQrGenerator(
    {required BuildContext context,
    required String shareLink,
    required double amount}) {
  showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 1,
    builder: (context) => QrGeneratorWidget(
      shareLink: shareLink,
      amount: amount,
    ),
  );
}
