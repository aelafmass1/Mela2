import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet_currency/wallet_currency_bloc.dart';
import '../../../../gen/colors.gen.dart';

class EnterAmountSection extends StatefulWidget {
  const EnterAmountSection({super.key});

  @override
  EnterAmountSectionState createState() => EnterAmountSectionState();
}

class EnterAmountSectionState extends State<EnterAmountSection> {
  final TextEditingController controller = TextEditingController();
  final FocusNode amountFocus = FocusNode();
  String selectedCurrency = 'usd';
  bool isSummerizing = false;
  final key = GlobalKey<FormState>();
  bool validated() {
    final validate = key.currentState?.validate();
    if (validate ?? false) {
      return true;
    }
    return false;
  }

  void setSummerizing() {
    setState(() {
      isSummerizing = !isSummerizing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Enter Amount',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        if (isSummerizing)
          Row(
            children: [
              TextWidget(
                text: 'Today\'s Exchange Rate',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              const Gap(8),
              const TextWidget(
                text: '1 USD = 124.02 JPY',
                fontSize: 14,
                color: ColorName.primaryColor,
                weight: FontWeight.bold,
              ),
            ],
          ),
        const Gap(8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Form(
            key: key,
            child: isSummerizing ? _buildOnSummerizing() : _buildOnInitial(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  TextFieldWidget _buildOnInitial() {
    return TextFieldWidget(
      onTapOutside: () {
        amountFocus.unfocus();
      },
      focusNode: amountFocus,
      onChanged: (p0) {
        if (p0.isNotEmpty) {
          setState(() {});
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (text) {
        if (text?.isEmpty == true) {
          return 'Amount is Empty';
        }
        return null;
      },
      keyboardType: TextInputType.phone,
      fontSize: 20,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      hintText: '00.00',
      prefixText: '\$',
      borderRadius: BorderRadius.circular(24),
      controller: controller,
      suffix: BlocBuilder<WalletCurrencyBloc, WalletCurrencyState>(
        builder: (context, state) {
          if (state is FetchWalletCurrencySuccess) {
            return Container(
              margin: const EdgeInsets.only(right: 3, top: 3, bottom: 3),
              width: 102,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: state.currencies.isNotEmpty
                  ? DropdownButton(
                      underline: const SizedBox.shrink(),
                      value: selectedCurrency,
                      items: [
                        for (var currency in state.currencies)
                          DropdownMenuItem(
                            value: currency.toLowerCase(),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'icons/currency/${currency.toLowerCase()}.png',
                                    fit: BoxFit.cover,
                                    package: 'currency_icons',
                                  ),
                                ),
                                const SizedBox(width: 5),
                                TextWidget(
                                  text: currency,
                                  fontSize: 12,
                                  weight: FontWeight.w700,
                                ),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        if (value is String?) {
                          setState(() {
                            selectedCurrency = value ?? 'usd';
                          });
                        }
                      })
                  : const SizedBox.shrink(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Stack _buildOnSummerizing() {
    return Stack(
      children: [
        Column(
          children: [
            TextFieldWidget(
              onChanged: (p0) {
                if (p0.isNotEmpty) {
                  setState(() {});
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return null;
              },
              keyboardType: TextInputType.phone,
              fontSize: 20,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              hintText: '00.00',
              prefixText: '\$',
              borderRadius: BorderRadius.circular(24),
              controller: TextEditingController(),
              suffix: BlocBuilder<WalletCurrencyBloc, WalletCurrencyState>(
                builder: (context, state) {
                  if (state is FetchWalletCurrencySuccess) {
                    return Container(
                      margin:
                          const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                      width: 102,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: state.currencies.isNotEmpty
                          ? DropdownButton(
                              underline: const SizedBox.shrink(),
                              value: selectedCurrency,
                              items: [
                                for (var currency in state.currencies)
                                  DropdownMenuItem(
                                    value: currency.toLowerCase(),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            'icons/currency/${currency.toLowerCase()}.png',
                                            fit: BoxFit.cover,
                                            package: 'currency_icons',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        TextWidget(
                                          text: currency,
                                          fontSize: 12,
                                          weight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                              onChanged: (value) {
                                if (value is String?) {
                                  setState(() {
                                    selectedCurrency = value ?? 'usd';
                                  });
                                }
                              })
                          : const SizedBox.shrink(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const Gap(10),
            TextFieldWidget(
              focusNode: amountFocus,
              onChanged: (p0) {
                if (p0.isNotEmpty) {
                  setState(() {});
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                return null;
              },
              keyboardType: TextInputType.phone,
              fontSize: 20,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              hintText: '00.00',
              prefixText: '\$',
              borderRadius: BorderRadius.circular(24),
              controller: controller,
              suffix: BlocBuilder<WalletCurrencyBloc, WalletCurrencyState>(
                builder: (context, state) {
                  if (state is FetchWalletCurrencySuccess) {
                    return Container(
                      margin:
                          const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                      width: 102,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: state.currencies.isNotEmpty
                          ? DropdownButton(
                              underline: const SizedBox.shrink(),
                              value: selectedCurrency,
                              items: [
                                for (var currency in state.currencies)
                                  DropdownMenuItem(
                                    value: currency.toLowerCase(),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            'icons/currency/${currency.toLowerCase()}.png',
                                            fit: BoxFit.cover,
                                            package: 'currency_icons',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        TextWidget(
                                          text: currency,
                                          fontSize: 12,
                                          weight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                              onChanged: (value) {
                                if (value is String?) {
                                  setState(() {
                                    selectedCurrency = value ?? 'usd';
                                  });
                                }
                              })
                          : const SizedBox.shrink(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            )
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          top: 0,
          left: 0,
          child: Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: ColorName.primaryColor,
              child: SvgPicture.asset(
                Assets.images.svgs.transactionIconVertical,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
