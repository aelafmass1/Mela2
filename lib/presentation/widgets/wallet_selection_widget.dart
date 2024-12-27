import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../bloc/wallet/wallet_bloc.dart';
import '../../data/models/wallet_model.dart';
import 'card_widget.dart';
import 'text_widget.dart';

class WalletSelectionWidget extends StatefulWidget {
  final List<WalletModel>? wallets;
  final int? selectedWalletId;
  final Function(WalletModel selectedWallet) onSelect;
  const WalletSelectionWidget({
    super.key,
    required this.onSelect,
    this.wallets,
    required this.selectedWalletId,
  });

  @override
  State<WalletSelectionWidget> createState() => _WalletSelectionWidgetState();
}

class _WalletSelectionWidgetState extends State<WalletSelectionWidget> {
  int selectedWalletIndex = -1;

  @override
  void initState() {
    log(widget.selectedWalletId.toString());
    log(widget.wallets.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.sh,
      width: 100.sw,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Change Wallet',
                      fontSize: 16,
                      weight: FontWeight.w700,
                    ),
                    TextWidget(
                      text: 'Lorem ipsum dolor sit amet consectetur. Non.',
                      fontSize: 10,
                      weight: FontWeight.w400,
                    )
                  ],
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  color: Colors.black,
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                  if (widget.wallets != null) {
                    return Column(
                      children: [
                        for (int i = 0; i < (widget.wallets?.length ?? 0); i++)
                          if (widget.wallets?[i].walletId !=
                              widget.selectedWalletId)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CardWidget(
                                  boxBorder: Border.all(
                                    color: selectedWalletIndex == i
                                        ? ColorName.primaryColor
                                        : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  borderRadius: BorderRadius.circular(24),
                                  width: 100.sw,
                                  height: 65,
                                  child: ListTile(
                                    shape: ContinuousRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    onTap: () {
                                      setState(() {
                                        selectedWalletIndex = i;
                                      });
                                    },
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: Image.asset(
                                        'icons/currency/${widget.wallets![i].currency.code.toLowerCase()}.png',
                                        package: 'currency_icons',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text:
                                              '${widget.wallets![i].currency.code.toUpperCase()} Wallet',
                                          fontSize: 14,
                                        ),
                                        // TextWidget(
                                        //   text:
                                        //       '${widget.wallets![i].currency.code.toUpperCase()} ${NumberFormat('##,###.##').format(state.wallets[i].balance)}',
                                        //   fontSize: 10,
                                        // )
                                      ],
                                    ),
                                    trailing: Checkbox(
                                      shape: const CircleBorder(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedWalletIndex = i;
                                        });
                                      },
                                      value: selectedWalletIndex == i,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < state.wallets.length; i++)
                        if (state.wallets[i].walletId !=
                            widget.selectedWalletId)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardWidget(
                                boxBorder: Border.all(
                                  color: selectedWalletIndex == i
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
                                      selectedWalletIndex = i;
                                    });
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    child: Image.asset(
                                      'icons/currency/${state.wallets[i].currency.code.toLowerCase()}.png',
                                      package: 'currency_icons',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text:
                                            '${state.wallets[i].currency.code.toUpperCase()} Wallet',
                                        fontSize: 14,
                                      ),
                                      TextWidget(
                                        text:
                                            '${state.wallets[i].currency.code.toUpperCase()} ${NumberFormat('##,###.##').format(state.wallets[i].balance)}',
                                        fontSize: 10,
                                      )
                                    ],
                                  ),
                                  trailing: Checkbox(
                                    shape: const CircleBorder(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedWalletIndex = i;
                                      });
                                    },
                                    value: selectedWalletIndex == i,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                          )
                    ],
                  );
                }),
              ),
            ),
            ButtonWidget(
              onPressed: selectedWalletIndex == -1
                  ? null
                  : () {
                      if (selectedWalletIndex != -1) {
                        if (widget.wallets == null) {
                          final state = context.read<WalletBloc>().state;
                          widget.onSelect(state.wallets[selectedWalletIndex]);
                        } else {
                          widget.onSelect(widget.wallets![selectedWalletIndex]);
                        }
                      }
                      context.pop();
                    },
              child: const TextWidget(
                text: 'Continue',
                color: Colors.white,
                type: TextType.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
