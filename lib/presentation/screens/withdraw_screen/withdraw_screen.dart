import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet_currency/wallet_currency_bloc.dart';
import '../../../core/utils/show_change_wallet_modal.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../data/models/wallet_model.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../tabs/home_tab/widgets/wallet_card.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_field_widget.dart';
import '../../widgets/text_widget.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String selectedCurrency = 'usd';

  WalletModel? selectedWalletModel;
  int selectBankAccountIndex = -1;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<WalletCurrencyBloc>().add(FetchWalletCurrency());
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 70,
          leadingWidth: 55,
          centerTitle: true,
          title: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state.wallets.isNotEmpty) {
                return selectedWalletModel != null
                    ? GestureDetector(
                        onTap: () async {
                          final w =
                              await showChangeWalletModal(context: context);
                          if (w != null) {
                            setState(() {
                              selectedWalletModel = w;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextWidget(
                              text:
                                  '\$${NumberFormat('##,###.##').format(selectedWalletModel!.balance)}',
                              weight: FontWeight.w700,
                              type: TextType.small,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget(
                                  text:
                                      '${selectedWalletModel!.currency} Wallet',
                                  fontSize: 10,
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          final w =
                              await showChangeWalletModal(context: context);
                          if (w != null) {
                            setState(() {
                              selectedWalletModel = w;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextWidget(
                              text:
                                  '\$${NumberFormat('##,###.##').format(state.wallets.first.balance)}',
                              weight: FontWeight.w700,
                              type: TextType.small,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget(
                                  text:
                                      '${state.wallets.first.currency} Wallet',
                                  fontSize: 10,
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                ),
                              ],
                            )
                          ],
                        ),
                      );
              }
              return const TextWidget(
                text: "No Wallet Found",
                type: TextType.small,
                weight: FontWeight.w400,
              );
            },
          )),
      body: BlocConsumer<WalletCurrencyBloc, WalletCurrencyState>(
        listener: (context, state) {
          if (state is FetchWalletCurrencyFail) {
            showSnackbar(context, description: state.reason);
          }
        },
        builder: (context, state) {
          if (state is FetchWalletCurrencyLoading) {
            return const Center(
                child: LoadingWidget(
              color: ColorName.primaryColor,
            ));
          } else if (state is FetchWalletCurrencySuccess) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildTop(),
                        _buildWithdrawTo(),
                        _buildAmountTextInput(state.currencies),
                        _buildNote(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ButtonWidget(
                      child: const TextWidget(
                        text: 'Continue',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        //
                      }),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  _buildTop() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state.wallets.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: selectedWalletModel != null
                      ? WalletCard(
                          height: 120,
                          showPattern: true,
                          walletName: '${selectedWalletModel!.currency} Wallet',
                          logo:
                              'icons/currency/${selectedWalletModel!.currency.toLowerCase()}.png',
                          amount: selectedWalletModel!.balance.toDouble(),
                          color: const Color(0xFF3440EC),
                        )
                      : WalletCard(
                          height: 120,
                          showPattern: true,
                          walletName: '${state.wallets.first.currency} Wallet',
                          logo:
                              'icons/currency/${state.wallets.first.currency.toLowerCase()}.png',
                          amount: state.wallets.first.balance.toDouble(),
                          color: const Color(0xFF3440EC),
                        ),
                );
              }
              return const SizedBox(
                height: 120,
                child: Center(
                  child: TextWidget(
                    text: "No Wallet Found",
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 123,
              height: 35,
              child: ButtonWidget(
                topPadding: 0,
                verticalPadding: 0,
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.images.svgs.walletLogo),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Change Wallet',
                      fontSize: 12,
                      color: ColorName.primaryColor,
                    )
                  ],
                ),
                onPressed: () async {
                  final selectedWallet =
                      await showChangeWalletModal(context: context);
                  if (selectedWallet != null) {
                    setState(() {
                      selectedWalletModel = selectedWallet;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  _buildWithdrawTo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: 'Withdraw To',
                weight: FontWeight.w700,
                type: TextType.small,
              ),
              TextButton(
                  onPressed: () {
                    //
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: ColorName.primaryColor,
                      ),
                      SizedBox(width: 5),
                      TextWidget(
                        text: 'Add Bank Account',
                        color: ColorName.primaryColor,
                        fontSize: 12,
                      ),
                    ],
                  ))
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CardWidget(
                boxBorder: Border.all(
                  color: selectBankAccountIndex == i
                      ? ColorName.primaryColor
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                borderRadius: BorderRadius.circular(24),
                width: 100.sw,
                height: 65,
                child: ListTile(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  onTap: () {
                    setState(() {
                      selectBankAccountIndex = i;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: Container(
                    width: 44,
                    height: 44,
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorName.primaryColor,
                    ),
                    child: SvgPicture.asset(Assets.images.svgs.bankLogo),
                  ),
                  title: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Bank Account',
                        fontSize: 14,
                      ),
                      TextWidget(
                        text: '10001800110011001',
                        fontSize: 10,
                        color: ColorName.grey,
                      )
                    ],
                  ),
                  trailing: Checkbox(
                    shape: const CircleBorder(),
                    onChanged: (value) {
                      setState(() {
                        selectBankAccountIndex = i;
                      });
                    },
                    value: selectBankAccountIndex == i,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _buildAmountTextInput(List currencies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Enter Amount',
              weight: FontWeight.w700,
              type: TextType.small,
            ),
            const SizedBox(height: 15),
            TextFieldWidget(
              enabled: selectBankAccountIndex != -1,
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
              controller: amountController,
              suffix: Container(
                margin: const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                width: 102,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(
                    30,
                  ),
                ),
                child: currencies.isNotEmpty
                    ? DropdownButton(
                        underline: const SizedBox.shrink(),
                        value: selectedCurrency,
                        items: [
                          for (var currency in currencies)
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextWidget(
            text: 'Note',
            weight: FontWeight.w700,
            type: TextType.small,
          ),
          const SizedBox(height: 15),
          TextFieldWidget(
            maxLines: 3,
            borderRadius: BorderRadius.circular(10),
            controller: noteController,
            hintText: 'Write your note',
          )
        ],
      ),
    );
  }
}
