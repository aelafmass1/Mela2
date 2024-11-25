import 'dart:developer';
import 'dart:math' as math;

import 'package:card_stack_widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/extensions/color_extension.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/wallet_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet/wallet_bloc.dart';

class WalletCardsStack extends StatefulWidget {
  final Function(String currencyCode) onTopChange;
  const WalletCardsStack({super.key, required this.onTopChange});

  @override
  State<WalletCardsStack> createState() => _WalletCardsStackState();
}

class _WalletCardsStackState extends State<WalletCardsStack> {
  final random = math.Random();
  double stackHeight = 190;
  bool walletTapped = false;
  List<WalletModel> tappedWallets = [];
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: stackHeight,
      width: 93.sw,
      child: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is FetchWalletSuccess) {
            setState(() {
              walletTapped = false;
              stackHeight = 190;
            });
            if (state.wallets.length > 1) {
              setState(() {
                stackHeight = stackHeight + ((state.wallets.length - 1) * 60);
              });
            }
            if (walletTapped) {
              tappedWallets.clear();
              setState(() {
                tappedWallets = state.wallets;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is FetchWalletsLoading) {
            return Stack(
              children: [
                // CustomShimmer(
                //   borderRadius: BorderRadius.circular(24),
                //   width: 93.sw,
                //   height: 160,
                // ),
                CustomShimmer(
                  baseColor: ColorName.primaryColor.shade300,
                  borderRadius: BorderRadius.circular(24),
                  width: 93.sw,
                  height: 160,
                ),
              ],
            );
          }
          if (state.wallets.isEmpty) {
            return const Center(
              child: TextWidget(
                text: 'No Wallet Found!',
                type: TextType.small,
              ),
            );
          } else {
            return CardStackWidget(
              opacityChangeOnDrag: false,
              swipeOrientation: CardOrientation.both,
              cardDismissOrientation: CardOrientation.both,
              positionFactor: 3,
              scaleFactor: 0.3,
              alignment: Alignment.center,
              reverseOrder: true,
              animateCardScale: true,
              dismissedCardDuration: const Duration(milliseconds: 600),
              cardList: [
                if (walletTapped)
                  for (int i = 0; i < tappedWallets.length; i++)
                    CardModel(
                        shadowBlurRadius: 0,
                        radius: const Radius.circular(24),
                        border: Border.all(color: Colors.transparent, width: 0),
                        child: WalletCard(
                          showPattern: i % 2 == 0,
                          walletName:
                              '${tappedWallets[i].currency.code} Wallet',
                          logo:
                              'icons/currency/${tappedWallets[i].currency.code.toLowerCase()}.png',
                          amount: tappedWallets[i].balance?.toDouble() ?? 0,
                          textColor:
                              tappedWallets[i].currency.textColor?.toColor(),
                          color: tappedWallets[i]
                                  .currency
                                  .backgroundColor
                                  ?.toColor() ??
                              Color.fromARGB(
                                255, // Set alpha to fully opaque
                                random.nextInt(256), // Red channel
                                random.nextInt(256), // Green channel
                                random.nextInt(256), // Blue channel
                              ),
                          onTab: () {
                            log("tapped ${tappedWallets.length}");
                            log("wallets ${state.wallets.length}");

                            final currentWallet = tappedWallets[i];
                            tappedWallets.clear();
                            tappedWallets.add(currentWallet);
                            for (var w in state.wallets) {
                              if (tappedWallets.contains(w) == false) {
                                tappedWallets.add(w);
                              }
                            }

                            setState(() {
                              walletTapped = true;
                              tappedWallets = tappedWallets;
                            });
                            widget
                                .onTopChange(tappedWallets.first.currency.code);
                          },
                        ))
                else
                  for (int i = 0; i < state.wallets.length; i++)
                    CardModel(
                        shadowBlurRadius: 0,
                        radius: const Radius.circular(24),
                        border: Border.all(color: Colors.transparent, width: 0),
                        child: WalletCard(
                          showPattern: i % 2 == 0,
                          walletName:
                              '${state.wallets[i].currency.code} Wallet',
                          logo:
                              'icons/currency/${state.wallets[i].currency.code.toLowerCase()}.png',
                          amount: state.wallets[i].balance?.toDouble() ?? 0,
                          textColor:
                              state.wallets[i].currency.textColor?.toColor(),
                          color: state.wallets[i].currency.backgroundColor
                                  ?.toColor() ??
                              Color.fromARGB(
                                255, // Set alpha to fully opaque
                                random.nextInt(256), // Red channel
                                random.nextInt(256), // Green channel
                                random.nextInt(256), // Blue channel
                              ),
                          onTab: () {
                            tappedWallets.clear();
                            tappedWallets.add(state.wallets[i]);
                            for (var w in state.wallets) {
                              if (tappedWallets.contains(w) == false) {
                                tappedWallets.add(w);
                              }
                            }
                            setState(() {
                              walletTapped = true;
                              tappedWallets = tappedWallets;
                            });
                            widget
                                .onTopChange(tappedWallets.first.currency.code);
                          },
                        ))
              ],
            );
          }
          // return Stack(
          //   children: [
          //     if (state.wallets.isNotEmpty)
          //       WalletCard(
          //         showPattern: false,
          //         walletName: '${state.wallets.first.currency} Wallet',
          //         logo:
          //             'icons/currency/${state.wallets.first.currency.toLowerCase()}.png',
          //         amount: state.wallets.first.balance.toDouble(),
          //         color: const Color(0xFF3440EC),
          //       )
          //     else
          //       const Center(
          //         child: TextWidget(
          //           text: "No Wallet Found",
          //           type: TextType.small,
          //         ),
          //       ),
          //     for (int i = 1; i < state.wallets.length; i++)
          //       Positioned(
          //         top: (50 * i).toDouble(),
          //         child: WalletCard(
          //           showPattern: i % 2 != 0,
          //           walletName: '${state.wallets[i].currency} Wallet',
          //           logo:
          //               'icons/currency/${state.wallets[i].currency.toLowerCase()}.png',
          //           amount: state.wallets[i].balance.toDouble(),
          //           color: Color.fromARGB(
          //             255, // Set alpha to fully opaque
          //             random.nextInt(256), // Red channel
          //             random.nextInt(256), // Green channel
          //             random.nextInt(256), // Blue channel
          //           ),
          //         ),
          //       ),
          //   ],
          // );
        },
      ),
    );
  }
}
