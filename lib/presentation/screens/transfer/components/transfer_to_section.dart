import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/borderd_rounded_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet/wallet_bloc.dart';

class TransferWalletsSection extends StatefulWidget {
  const TransferWalletsSection({super.key});

  @override
  TransferWalletsSectionState createState() => TransferWalletsSectionState();
}

class TransferWalletsSectionState extends State<TransferWalletsSection> {
  int selectedWallet = 0;
  int selectedWalletIndex = 0;
  bool isSummerizing = false;
  @override
  void initState() {
    final state = context.read<WalletBloc>().state;
    selectedWalletIndex = 0;
    selectedWallet = state.wallets[0].walletId;
    super.initState();
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
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        BlocConsumer<WalletBloc, WalletState>(builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: (isSummerizing)
                    ? CardWidget(
                        boxBorder: Border.all(color: ColorName.primaryColor),
                        alignment: Alignment.center,
                        borderRadius: BorderRadius.circular(24),
                        width: 100.sw,
                        height: 65,
                        child: ListTile(
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onTap: () {},
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          leading: Container(
                            width: 44,
                            height: 44,
                            clipBehavior: Clip.antiAlias,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: Image.asset(
                              'icons/currency/${state.wallets[selectedWalletIndex].currency.toLowerCase()}.png',
                              package: 'currency_icons',
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text:
                                    '${state.wallets[selectedWalletIndex].currency.toUpperCase()} Wallet',
                                fontSize: 14,
                              ),
                              TextWidget(
                                text:
                                    '${state.wallets[selectedWalletIndex].currency.toUpperCase()} ${NumberFormat('##,###.##').format(state.wallets[selectedWalletIndex].balance)}',
                                fontSize: 10,
                              )
                            ],
                          ),
                          trailing: BorderdRoundedButton(
                              text: "Change",
                              onTap: () {
                                setSummerizing();
                              }),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < state.wallets.length; i++)
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
                                        selectedWallet =
                                            state.wallets[i].walletId;
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
                                        'icons/currency/${state.wallets[i].currency.toLowerCase()}.png',
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
                                              '${state.wallets[i].currency.toUpperCase()} Wallet',
                                          fontSize: 14,
                                        ),
                                        TextWidget(
                                          text:
                                              '${state.wallets[i].currency.toUpperCase()} ${NumberFormat('##,###.##').format(state.wallets[i].balance)}',
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
                      ),
              ),
            ],
          );
        }, listener: (BuildContext context, WalletState state) {
          selectedWallet = state.wallets.firstOrNull?.walletId ?? 0;
        }),
        if (!isSummerizing)
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: ColorName.primaryColor,
                  backgroundColor: Colors.white,
                  elevation: 7,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      TextWidget(
                        text: 'Add New Card',
                        color: ColorName.primaryColor,
                        fontSize: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class TransferToUserSection extends StatefulWidget {
  const TransferToUserSection({super.key, required this.onChangePressed});
  final VoidCallback onChangePressed;
  @override
  State<TransferToUserSection> createState() => _TransferToUserSectionState();
}

class _TransferToUserSectionState extends State<TransferToUserSection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        CardWidget(
            width: size.width,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        const NetworkImage('https://picsum.photos/200'),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: const Text("John Doe"),
                  subtitle: const Text("+1408-010-1010"),
                  trailing: BorderdRoundedButton(
                    text: 'Change',
                    onTap: widget.onChangePressed,
                  ),
                ))),
      ],
    );
  }
}

class TransferToPhoneNumberSection extends StatefulWidget {
  const TransferToPhoneNumberSection({
    super.key,
  });
  @override
  State<TransferToPhoneNumberSection> createState() =>
      _TransferToPhoneNumberSectionState();
}

class _TransferToPhoneNumberSectionState
    extends State<TransferToPhoneNumberSection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        CardWidget(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  SvgPicture.asset(Assets.images.svgs.circularUserIcon),
                  const TextWidget(text: "+1408-010-1010")
                ],
              ),
            )),
      ],
    );
  }
}
