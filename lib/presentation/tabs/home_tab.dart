import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: 'Good Morning',
                fontSize: 14,
              ),
              const TextWidget(
                text: 'Amanuel',
                fontSize: 24,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'enter Money amount',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                        ),
                        prefixIcon: Assets.images.dollar.image(
                          height: 25,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ButtonWidget(
                      borderRadius: BorderRadius.circular(10),
                      child: const TextWidget(
                        text: 'Send',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  width: 100.sh,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    border: Border.all(
                      color: const Color(0xFF4D4D4D).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextWidget(
                          text: 'Today’s  Exchange Rate',
                          fontSize: 14,
                          color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        ),
                      ),
                      Container(
                        width: 100.sh,
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: const Color(0xFF4D4D4D).withOpacity(0.05),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              text: 'Banks',
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            ),
                            TextWidget(
                              text: 'Buying (ETB)',
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            ),
                            TextWidget(
                              text: 'Action',
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildBankTile(
                                bankName: 'CBE',
                                buyingAmount: '95.6931',
                                imagePath: Assets.images.cbeLogo.path,
                                tipAmount: '-40%',
                              ),
                              _buildBankTile(
                                bankName: 'Abyssinia Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.abysiniaLogo.path,
                                tipAmount: '+40%',
                                tipColor: ColorName.green,
                              ),
                              _buildBankTile(
                                bankName: 'Amhara Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.amaraBankLogo.path,
                                tipAmount: '+40%',
                              ),
                              _buildBankTile(
                                bankName: 'Ahadu Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.ahaduLogo.path,
                                tipAmount: '-40%',
                              ),
                              _buildBankTile(
                                bankName: 'Coop Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.bankOfOromo.path,
                                tipAmount: '+40%',
                                tipColor: ColorName.green,
                              ),
                              _buildBankTile(
                                bankName: 'Bunk Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.bunaBank.path,
                                tipAmount: '+40%',
                                tipColor: ColorName.green,
                              ),
                              _buildBankTile(
                                bankName: 'Awash Bank',
                                buyingAmount: '95.6931 ',
                                imagePath: Assets.images.awashBank.path,
                                tipAmount: '+40%',
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  _buildBankTile({
    required String bankName,
    required String imagePath,
    required String buyingAmount,
    required String tipAmount,
    Color? tipColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: 45,
                    height: 45,
                  ),
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: bankName,
                  fontSize: 10,
                  color: const Color(0xFF4D4D4D),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: TextWidget(
                  text: buyingAmount,
                  fontSize: 13,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: TextWidget(
                  text: tipAmount,
                  color: tipColor ?? ColorName.red,
                  fontSize: 7,
                ),
              )
            ],
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                shape: ContinuousRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: ColorName.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                //
              },
              child: const TextWidget(
                text: 'Send',
                type: TextType.small,
                color: ColorName.borderColor,
              ))
        ],
      ),
    );
  }
}
