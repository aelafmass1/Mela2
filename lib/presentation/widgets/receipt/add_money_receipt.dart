// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:transaction_mobile_app/presentation/widgets/receipt/utils.dart';

import '../../../gen/colors.gen.dart';
import '../text_widget.dart';

class AddMoneyReceipt extends StatelessWidget {
  final WalletTransactionModel walletTransactionModel;
  const AddMoneyReceipt({super.key, required this.walletTransactionModel});

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
        padding: const EdgeInsets.symmetric(horizontal: 25),
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
                        top: 92,
                        left: 0,
                        right: 0,
                        child: Align(
                          child: Column(
                            children: [
                              TextWidget(
                                text: '\$${walletTransactionModel.amount}',
                                color: getStatusDetails(
                                    walletTransactionModel.status)['textColor'],
                                weight: FontWeight.w600,
                              ),
                              SizedBox(
                                width: 60.sw,
                                child: TextWidget(
                                  text:
                                      'Money has been successfully added to ${walletTransactionModel.fromWallet?.currency.code ?? 'your'} wallet.',
                                  textAlign: TextAlign.center,
                                  fontSize: 14,
                                  weight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildTransactionDetail(
                                key: 'Transaction Type',
                                value: walletTransactionModel.transactionType,
                              ),
                              _buildTransactionDetail(
                                key: 'From',
                                value: walletTransactionModel.from,
                              ),
                              _buildTransactionDetail(
                                key: 'Amount',
                                value: walletTransactionModel.amount.toString(),
                              ),
                              _buildTransactionDetail(
                                key: 'Date',
                                value: DateFormat('MMMM dd, yyyy')
                                    .format(DateTime.now()),
                              ),
                              _buildTransactionDetail(
                                  key: 'Transaction ID',
                                  value: walletTransactionModel.transactionId
                                      .toString()),
                              _buildTransactionDetail(
                                  key: 'Transaction Status',
                                  value: getStatusDetails(
                                      walletTransactionModel.status ??
                                          "SUCCESS")['normalizedText'],
                                  color: getStatusDetails(
                                      walletTransactionModel.status ??
                                          "SUCCESS")['textColor']),
                              _buildTransactionDetail(
                                key: 'Remark ',
                                value: (walletTransactionModel.note?.length ??
                                            0) >
                                        20
                                    ? '${walletTransactionModel.note!.substring(0, 20)}...'
                                    : walletTransactionModel.note ?? '',
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ButtonWidget(
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
            const SizedBox(height: 5),
            SizedBox(
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildTransactionDetail(
      {required String key,
      required String value,
      Color color = const Color(0xFF7B7B7B)}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: key,
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
          const SizedBox(height: 5),
          const Divider(
            color: ColorName.borderColor,
          )
        ],
      ),
    );
  }
}
