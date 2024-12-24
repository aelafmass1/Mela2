// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/ui_helpers.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/core/utils/get_status_details.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../gen/colors.gen.dart';

class WalletReceiptWidget extends StatelessWidget {
  final WalletTransactionModel walletTransactionModel;
  final List<List<String>> contents;
  final String amount;
  final String message;
  const WalletReceiptWidget({
    super.key,
    required this.walletTransactionModel,
    required this.contents,
    required this.amount,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final globalKey = GlobalKey();
    //
    Future<void> captureAndConvertToPdf(BuildContext context) async {
      final boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Image(imageProvider),
          ),
        ),
      );

      // Save or share the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: [
                    getStatusDetails(walletTransactionModel.status)['bgImage'],
                    Positioned(
                      top: 87,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          TextWidget(
                            text: amount,
                            color: getStatusDetails(
                                walletTransactionModel.status)['textColor'],
                            weight: FontWeight.w600,
                          ),
                          SizedBox(
                            width: 60.sw,
                            child: TextWidget(
                              text: message,
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              weight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 45),
                          for (var content in contents)
                            TransactionDetail(
                              keyText: content[0],
                              value: content[1],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: walletTransactionModel.status == "SUCCESS" ? 10 : 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ButtonWidget(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Bootstrap.download,
                        size: 20,
                      ),
                      SizedBox(width: 20),
                      TextWidget(
                        text: 'Download Receipt',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onPressed: () {
                    captureAndConvertToPdf(context);
                    context.pop();
                  }),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 100.sw,
                height: 55,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const TextWidget(
                      text: 'Finish',
                      type: TextType.small,
                      color: ColorName.primaryColor,
                    ),
                    onPressed: () {
                      context.pop();
                    }),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class TransactionDetail extends StatelessWidget {
  final String keyText;
  final String value;
  final Color color;

  const TransactionDetail({
    super.key,
    required this.keyText,
    required this.value,
    this.color = const Color(0xFF7B7B7B),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: keyText,
                  color: const Color(0xFF7B7B7B),
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                TextWidget(
                  text: value,
                  color: color,
                  fontSize: 16,
                  weight: FontWeight.w400,
                )
              ],
            ),
          ),
          const SizedBox(height: tinySize),
          const Divider(
            color: ColorName.borderColor,
            endIndent: middleSize,
            indent: middleSize,
          )
        ],
      ),
    );
  }
}
