import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPage extends StatelessWidget {
  final ReceiverInfo receiverInfo;
  ReceiptPage({super.key, required this.receiverInfo});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: [
                    Assets.images.receipt.image(
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        child: Align(
                          child: Column(
                            children: [
                              TextWidget(
                                text: '\$${receiverInfo.amount}',
                                color: ColorName.primaryColor,
                                weight: FontWeight.w600,
                              ),
                              SizedBox(
                                width: 45.sw,
                                child: TextWidget(
                                  text:
                                      'You have sent \$${receiverInfo.amount} to ${receiverInfo.receiverName} Successfully',
                                  textAlign: TextAlign.center,
                                  fontSize: 14,
                                  weight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 35),
                              _buildTransactionDetail(
                                  key: 'Date',
                                  value: DateFormat('MMMM dd, yyyy')
                                      .format(DateTime.now())),
                              _buildTransactionDetail(
                                key: 'To',
                                value: receiverInfo.receiverName.trim() ==
                                        'null null'
                                    ? 'Unregsistered User'
                                    : receiverInfo.receiverName.trim(),
                              ),
                              _buildTransactionDetail(
                                key: 'From',
                                value: receiverInfo.lastDigit == null
                                    ? 'You'
                                    : '**** **** ${receiverInfo.lastDigit ?? ''}',
                              ),
                              _buildTransactionDetail(
                                key: 'Recipient Amount',
                                value: '\$${receiverInfo.amount}',
                              ),
                              _buildTransactionDetail(
                                key: 'Details',
                                value: receiverInfo.paymentType,
                              ),
                              _buildTransactionDetail(
                                key: 'Transaction ID',
                                value: '00000111100',
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 20, top: 10),
                              //   child: Row(
                              //     children: [
                              //       Assets.images.masteredCard.image(
                              //         fit: BoxFit.cover,
                              //       ),
                              //       const SizedBox(width: 15),
                              //       const Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           TextWidget(
                              //             text: 'Credit Card',
                              //             fontSize: 16,
                              //           ),
                              //           TextWidget(
                              //             text: 'Mastercard ending   ** 0011',
                              //             fontSize: 10,
                              //           ),
                              //         ],
                              //       )
                              //     ],
                              //   ),
                              // )
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildTransactionDetail({required String key, required String value}) {
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
                  color: const Color(0xFF7B7B7B),
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
