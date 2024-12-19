// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/currency/currency_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet/wallet_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_recent_transaction/wallet_recent_transaction_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_transaction/wallet_transaction_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/last_transaction.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/recent_wallet_transactions.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/wallet_options.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../config/routing.dart';
import '../../../data/services/observer/lifecycle_manager.dart';
import '../../screens/home_screen/components/exchange_rate_card.dart';
import 'components/wallet_cards_stack.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final moneyController = TextEditingController();
  String? imageUrl;
  String? displayName;
  String currencyCode = 'USD';
  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  void initState() {
    getImageUrl().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
    getDisplayName().then((value) {
      final names = value?.split(' ');
      if (names?.isNotEmpty ?? false) {
        setState(() {
          displayName = names?.first.toUpperCase();
        });
      }
    });
    getToken().then((token) {
      if (token == null) {
        showSnackbar(context, description: "Please Login to continue");
        context.goNamed(RouteName.loginPincode);
      }
    });
    LifecycleManager().onLogout = () {
      // Update app state or navigation stack
      MyAppRouter.instance.navigateToPincodeLogin();
    };

    context.read<WalletBloc>().add(FetchWallets());
    context.read<CurrencyBloc>().add(FetchAllCurrencies());
    context.read<WalletTransactionBloc>().add(
          FetchWalletTransaction(),
        );
    context.read<WalletRecentTransactionBloc>().add(
          FetchRecentTransaction(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 20,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    imageUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: imageUrl!,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return const SizedBox(
                                  width: 45,
                                  height: 45,
                                );
                              },
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage:
                                Assets.images.profileImage.provider(),
                          ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: getGreeting(),
                          fontSize: 14,
                          weight: FontWeight.w500,
                        ),
                        TextWidget(
                          text: displayName ?? '',
                          fontSize: 20,
                          weight: FontWeight.w800,
                          color: ColorName.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        //
                      },
                      icon: SvgPicture.asset(
                        Assets.images.svgs.qrcodeLogo,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          context.pushNamed(
                            RouteName.notification,
                          );
                        },
                        icon: const Icon(
                          Bootstrap.bell,
                          size: 24,
                        ))
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(FetchWallets());
              context.read<CurrencyBloc>().add(FetchAllCurrencies());
              context.read<WalletTransactionBloc>().add(
                    FetchWalletTransaction(),
                  );
              context.read<WalletRecentTransactionBloc>().add(
                    FetchRecentTransaction(),
                  );
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  WalletCardsStack(
                    onTopChange: (code) {
                      setState(() {
                        currencyCode = code;
                      }); 
                    },
                  ),
                  WalletOptions(
                    currencyCode: currencyCode,
                  ),
                  const RecentMembers(),
                  _buildExchangeRate(),
                  const LastTransaction(),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  _buildExchangeRate() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
      child: SizedBox(
        width: 100.sw,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Exchange Rate',
                      type: TextType.small,
                    ),
                    TextWidget(
                      text: 'Last Update 12/02/2024 - 03:00 PM',
                      fontSize: 10,
                      color: ColorName.grey,
                    ),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      //
                    },
                    child: const TextWidget(
                      text: 'View all',
                      fontSize: 12,
                      color: ColorName.primaryColor,
                    ))
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: BlocBuilder<CurrencyBloc, CurrencyState>(
                builder: (context, state) {
                  if (state is CurrencyLoading) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...List.generate(3, (index) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: CustomShimmer(
                                width: 200,
                                height: 90,
                              ),
                            );
                          })
                        ],
                      ),
                    );
                  } else if (state is CurrencySuccess) {
                    return Row(
                      children: [
                        for (var currency in state.currencies)
                          ExchangeRateCard(
                            currencyModel: currency,
                          ),
                      ],
                    );
                  }
                  return const SizedBox(
                    height: 90,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
