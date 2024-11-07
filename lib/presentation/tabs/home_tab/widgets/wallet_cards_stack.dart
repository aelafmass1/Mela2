import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/widgets/wallet_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet/wallet_bloc.dart';

class WalletCardsStack extends StatefulWidget {
  const WalletCardsStack({super.key});

  @override
  State<WalletCardsStack> createState() => _WalletCardsStackState();
}

class _WalletCardsStackState extends State<WalletCardsStack> {
  final random = math.Random();
  double stackHeight = 240;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: stackHeight,
      width: 93.sw,
      child: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is FetchWalletSuccess) {
            if (state.wallets.length > 2) {
              setState(() {
                stackHeight = stackHeight + ((state.wallets.length - 2) * 50);
              });
            }
          }
        },
        builder: (context, state) {
          if (state is FetchWalletsLoading) {
            return Stack(
              children: [
                CustomShimmer(
                  borderRadius: BorderRadius.circular(24),
                  width: 93.sw,
                  height: 160,
                ),
                Positioned(
                  top: 50,
                  child: CustomShimmer(
                    baseColor: ColorName.primaryColor.shade300,
                    borderRadius: BorderRadius.circular(24),
                    width: 93.sw,
                    height: 160,
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: [
              if (state.wallets.isNotEmpty)
                WalletCard(
                  showPattern: false,
                  walletName: '${state.wallets.first.currency} Wallet',
                  logo:
                      'icons/currency/${state.wallets.first.currency.toLowerCase()}.png',
                  amount: state.wallets.first.balance.toDouble(),
                  color: const Color(0xFF3440EC),
                )
              else
                const Center(
                  child: TextWidget(
                    text: "No Wallet Found",
                    type: TextType.small,
                  ),
                ),
              for (int i = 1; i < state.wallets.length; i++)
                Positioned(
                  top: (50 * i).toDouble(),
                  child: WalletCard(
                    showPattern: i % 2 != 0,
                    walletName: '${state.wallets[i].currency} Wallet',
                    logo:
                        'icons/currency/${state.wallets[i].currency.toLowerCase()}.png',
                    amount: state.wallets[i].balance.toDouble(),
                    color: Color.fromARGB(
                      255, // Set alpha to fully opaque
                      random.nextInt(256), // Red channel
                      random.nextInt(256), // Green channel
                      random.nextInt(256), // Blue channel
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
