import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet_currency/wallet_currency_bloc.dart';

class EnterAmountSection extends StatefulWidget {
  const EnterAmountSection({super.key});

  @override
  EnterAmountSectionState createState() => EnterAmountSectionState();
}

class EnterAmountSectionState extends State<EnterAmountSection> {
  final TextEditingController controller = TextEditingController();
  final FocusNode amountFocus = FocusNode();
  String selectedCurrency = 'usd';

  final key = GlobalKey<FormState>();
  bool validated() {
    if (key.currentState?.validate() == true) {
      return true;
    }
    return false;
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
        Form(
          key: key,
          child: TextFieldWidget(
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
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
