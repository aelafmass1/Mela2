import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: Stack(
                  children: [
                    Assets.images.receipt.image(
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                        top: 95,
                        left: 0,
                        right: 0,
                        child: Align(
                          child: Column(
                            children: [
                              const TextWidget(
                                text: '\$500',
                                color: ColorName.primaryColor,
                                weight: FontWeight.w600,
                              ),
                              SizedBox(
                                width: 45.sw,
                                child: const TextWidget(
                                  text:
                                      'You have sent \$500 to Account name Successfully',
                                  textAlign: TextAlign.center,
                                  fontSize: 14,
                                  weight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 45),
                              _buildTransactionDetail(
                                key: 'Date',
                                value: 'Nov 20, 2023',
                              ),
                              _buildTransactionDetail(
                                key: 'To',
                                value: 'Account Name',
                              ),
                              _buildTransactionDetail(
                                key: 'From',
                                value: '**** **** 0011',
                              ),
                              _buildTransactionDetail(
                                key: 'Recipient Amount',
                                value: '\$500',
                              ),
                              _buildTransactionDetail(
                                key: 'Details',
                                value: 'Equb Payment',
                              ),
                              _buildTransactionDetail(
                                key: 'Transaction ID',
                                value: '00000111100',
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 10),
                                child: Row(
                                  children: [
                                    Assets.images.masteredCard.image(
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 15),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Credit Card',
                                          fontSize: 16,
                                        ),
                                        TextWidget(
                                          text: 'Mastercard ending   ** 0011',
                                          fontSize: 10,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
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
                    //
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
