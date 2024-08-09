import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class SentTab extends StatefulWidget {
  const SentTab({super.key});

  @override
  State<SentTab> createState() => _SentTabState();
}

class _SentTabState extends State<SentTab> {
  bool showBankSelection = false;
  bool showTransaction = false;
  int selectedBankIndex = 0;
  String selectedBanks = '';
  double sliderWidth = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildExchangeRate(),
              _buildBankSelection(),
              _builTransaction(),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, left: 30, right: 30),
              height: 3,
              color: Colors.white,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: sliderWidth,
              margin: const EdgeInsets.only(top: 15, left: 30, right: 30),
              height: 3,
              color: ColorName.primaryColor,
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    ));
  }

  _buildExchangeRate() {
    return Visibility(
      visible: selectedBankIndex == 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              width: 100.sh,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4D4D4D).withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: 'They’re Receiving',
                    type: TextType.small,
                    color: Color(0xFF4D4D4D),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 22,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWidget(
                              text: 'USD',
                              color: const Color(0xFF4D4D4D).withOpacity(0.7),
                            ),
                            const SizedBox(width: 10),
                            Assets.images.usaFlag.image(),
                            const SizedBox(width: 15),
                          ],
                        )),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                left: 15, top: 12, bottom: 10),
                            height: 80,
                            width: 1,
                            color: Colors.grey,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 45, left: 10.5),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: ColorName.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextWidget(
                                text: 'Exchange rate',
                                type: TextType.small,
                                color: Color(0xFF4D4D4D),
                                weight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 12),
                            TextWidget(
                              text: '1 USD = 101.5 Birr',
                              type: TextType.small,
                              color: Color(0xFF4D4D4D),
                              weight: FontWeight.w500,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const TextWidget(
                    text: 'Recipient Gets',
                    type: TextType.small,
                    color: Color(0xFF4D4D4D),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 22,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWidget(
                              text: 'ETB',
                              color: const Color(0xFF4D4D4D).withOpacity(0.7),
                            ),
                            const SizedBox(width: 10),
                            Assets.images.ethiopianFlag.image(),
                            const SizedBox(width: 15),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Connected bank account (ACH) fee',
                        fontSize: 15,
                        color: const Color(0xFF4D4D4D).withOpacity(0.5),
                      ),
                      const TextWidget(
                        text: '2.92 USD',
                        fontSize: 15,
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Our fee',
                        fontSize: 15,
                        color: const Color(0xFF4D4D4D).withOpacity(0.5),
                      ),
                      const TextWidget(
                        text: '2.92 USD',
                        fontSize: 15,
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Total fees',
                        fontSize: 15,
                      ),
                      TextWidget(
                        text: ' 5.71 USD',
                        fontSize: 15,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ButtonWidget(
                  child: const TextWidget(
                    text: 'Next',
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedBankIndex = 1;
                      sliderWidth = 50.sw;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  _buildBankSelection() {
    return Visibility(
      visible: selectedBankIndex == 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackButtonWidget(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        selectedBankIndex = 0;
                        sliderWidth = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 15),
                  TextWidget(
                    text: 'Bank selection',
                    color: const Color(0xFF4D4D4D).withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  color: Colors.black.withOpacity(0.7),
                ),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWidget(
                          text: 'USD',
                          color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        ),
                        const SizedBox(width: 10),
                        Assets.images.usaFlag.image(),
                        const SizedBox(width: 15),
                      ],
                    )),
              ),
              const SizedBox(height: 30),
              Container(
                width: 100.sh,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: DropdownButton(
                    dropdownColor: ColorName.backgroundColor,
                    isExpanded: true,
                    hint: const TextWidget(
                      text: 'Select Bank',
                      weight: FontWeight.w300,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    borderRadius: BorderRadius.circular(15),
                    underline: const SizedBox.shrink(),
                    value: selectedBanks.isNotEmpty ? selectedBanks : null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    items: [
                      DropdownMenuItem(
                          value: 'cbe',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Assets.images.cbeLogo.image(),
                                const SizedBox(width: 20),
                                const TextWidget(
                                  text: 'CBE',
                                  type: TextType.small,
                                ),
                              ],
                            ),
                          )),
                      DropdownMenuItem(
                          value: 'abyssinia',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Assets.images.abysiniaLogo.image(),
                                const SizedBox(width: 20),
                                const TextWidget(
                                  text: 'Abyssinia Bank',
                                  type: TextType.small,
                                ),
                              ],
                            ),
                          )),
                      DropdownMenuItem(
                          value: 'amhara_bank',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Assets.images.amaraBankLogo.image(),
                                const SizedBox(width: 20),
                                const TextWidget(
                                  text: 'Amhara Bank',
                                  type: TextType.small,
                                ),
                              ],
                            ),
                          )),
                      DropdownMenuItem(
                          value: 'coop',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Assets.images.bankOfOromo.image(),
                                const SizedBox(width: 20),
                                const TextWidget(
                                  text: 'Coop Bank',
                                  type: TextType.small,
                                ),
                              ],
                            ),
                          )),
                      DropdownMenuItem(
                          value: 'ahadu_bank',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Assets.images.ahaduLogo.image(),
                                const SizedBox(width: 20),
                                const TextWidget(
                                  text: 'Ahadu Bank',
                                  type: TextType.small,
                                ),
                              ],
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedBanks = value;
                        });
                      }
                    }),
              ),
              const SizedBox(height: 30),
              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  color: Colors.black.withOpacity(0.7),
                ),
                decoration: InputDecoration(
                  hintText: 'Ethiopian Bank account number',
                  hintStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  contentPadding: const EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    left: 22,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ButtonWidget(
                child: const TextWidget(
                  text: 'Next',
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    selectedBankIndex = 2;
                    sliderWidth = 100.sw;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _builTransaction() {
    return Visibility(
      visible: selectedBankIndex == 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              BackButtonWidget(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    selectedBankIndex = 1;
                    sliderWidth = 50.sw;
                  });
                },
              ),
              Container(
                width: 100.sw,
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF404040).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: 'Payment Method',
                    ),
                    const TextWidget(
                      text: 'Select a payment method to pay',
                      weight: FontWeight.w300,
                      type: TextType.small,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: 100.sw,
                      padding: const EdgeInsets.only(left: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          // color: Colors.amber,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black54,
                          )),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextWidget(
                          text: 'Bank Account',
                          fontSize: 15,
                          color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 100.sw,
                      padding: const EdgeInsets.only(left: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          // color: Colors.amber,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black54,
                          )),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextWidget(
                          text: 'Debit Card',
                          fontSize: 15,
                          color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 100.sw,
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF404040).withOpacity(0.5),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Payment Information',
                    ),
                    TextWidget(
                      text: 'Review Transaction Information',
                      weight: FontWeight.w300,
                      type: TextType.small,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Name',
                          type: TextType.small,
                        ),
                        TextWidget(
                          text: 'Samuel Lakew',
                          type: TextType.small,
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Transaction No',
                          type: TextType.small,
                        ),
                        TextWidget(
                          text: '76654',
                          type: TextType.small,
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Account No',
                          type: TextType.small,
                        ),
                        TextWidget(
                          text: '10002348774',
                          type: TextType.small,
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Amount',
                          type: TextType.small,
                        ),
                        TextWidget(
                          text: '\$3212',
                          type: TextType.small,
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),
              ButtonWidget(
                  child: const TextWidget(
                    text: 'CONFIRM TRANSACTION',
                    color: Colors.white,
                    type: TextType.small,
                  ),
                  onPressed: () {}),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
