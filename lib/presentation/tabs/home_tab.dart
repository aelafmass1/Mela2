import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/bank_currency_rate/bank_currency_rate_bloc.dart';
import 'package:transaction_mobile_app/bloc/currency/currency_bloc.dart';
import 'package:transaction_mobile_app/core/utils/bank_image.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/home_screen/components/bank_rate_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../screens/home_screen/components/exchange_rate_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final moneyController = TextEditingController();
  getToken() async {
    final res = await FirebaseAuth.instance.currentUser!.getIdToken();
    log('Token -> ${res.toString()}');
  }

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
    getToken();
    context.read<BankCurrencyRateBloc>().add(FetchCurrencyRate());
    context.read<CurrencyBloc>().add(FetchAllCurrencies());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 10,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
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
                              text: FirebaseAuth
                                      .instance.currentUser?.displayName ??
                                  '',
                              fontSize: 20,
                              weight: FontWeight.w800,
                              color: ColorName.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          //
                        },
                        icon: const Icon(
                          Bootstrap.bell,
                          size: 24,
                        ))
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildPromotionalRate(),
                    _buildSendMoneyCard(),
                    _buildExchangeRate(),
                    _buildBankRates(),
                  ],
                ),
              ))
            ],
          )),
    );
  }

  _buildSendMoneyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: CardWidget(
        width: 100.sw,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Send Money',
              fontSize: 14,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: moneyController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Enter amount';
                }
                return null;
              },
              style: const TextStyle(
                fontSize: 18,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                    RegExp(r'^[0-9]*[.,]?[0-9]*$')),
              ],
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                hintText: 'Enter amount',
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFD0D0D0),
                ),
                suffixIcon: Container(
                  width: 90,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      width: 1,
                      color: Colors.black45,
                    ),
                  ),
                  child: Center(
                    child: DropdownButton(
                        value: 'usd',
                        elevation: 0,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          DropdownMenuItem(
                            value: 'usd',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.usaFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'USD',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'etb',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.ethiopianFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'ETB',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          //
                        }),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMoneyAmount(50),
                  _buildMoneyAmount(100),
                  _buildMoneyAmount(125),
                  _buildMoneyAmount(150),
                  _buildMoneyAmount(200),
                  _buildMoneyAmount(250),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              child: ButtonWidget(
                  verticalPadding: 0,
                  child: const TextWidget(
                    text: 'Next',
                    type: TextType.small,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    //
                  }),
            )
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 7),
              TextWidget(
                text: bankName.split(' ').removeAt(0),
                fontSize: 10,
                textAlign: TextAlign.center,
              )
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: TextWidget(
                  text: '$buyingAmount ETB',
                  fontSize: 13,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.increaseArrow,
                      width: 7,
                      // ignore: deprecated_member_use
                      color: tipColor ?? ColorName.red,
                    ),
                    const SizedBox(width: 5),
                    TextWidget(
                      text: tipAmount,
                      fontSize: 8,
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 32,
            width: 60,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: ColorName.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  //
                },
                child: const TextWidget(
                  text: 'Send',
                  type: TextType.small,
                  color: ColorName.primaryColor,
                )),
          )
        ],
      ),
    );
  }

  _buildPromotionalRate() {
    return Column(
      children: [
        SizedBox(
          width: 100.sw,
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: 100.sw,
                      height: 120,
                      decoration: BoxDecoration(
                        color: ColorName.primaryColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SvgPicture.asset(
                        Assets.images.svgs.cardPattern,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: TextWidget(
                              text: 'Our promotional rate',
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            width: 100.sw,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage:
                                          Assets.images.usaFlag.provider(),
                                    ),
                                    const SizedBox(width: 7),
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'US Dollar',
                                          fontSize: 9,
                                          weight: FontWeight.w500,
                                          color: ColorName.primaryColor,
                                        ),
                                        TextWidget(
                                          text: '1 USD',
                                          fontSize: 14,
                                          color: ColorName.primaryColor,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: ColorName.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.images.svgs.exchangeIcon,
                                    // ignore: deprecated_member_use
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage: Assets
                                          .images.ethiopianFlag
                                          .provider(),
                                    ),
                                    const SizedBox(width: 7),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const TextWidget(
                                          text: 'ET Birr',
                                          fontSize: 9,
                                          weight: FontWeight.w500,
                                          color: ColorName.primaryColor,
                                        ),
                                        BlocBuilder<CurrencyBloc,
                                            CurrencyState>(
                                          builder: (context, state) {
                                            if (state is CurrencyLoading) {
                                              return const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 3),
                                                child: CustomShimmer(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  width: 67,
                                                  height: 16,
                                                ),
                                              );
                                            }
                                            if (state is CurrencySuccess) {
                                              return TextWidget(
                                                text:
                                                    '${state.currencies.where((c) => c.currencyCode == 'USD').first.rate.toStringAsFixed(2)} ETB',
                                                fontSize: 14,
                                                color: ColorName.primaryColor,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8,
                height: 15,
                color: const Color(0xFFBFBFBF),
              ),
              Container(
                width: 8,
                height: 15,
                color: const Color(0xFFBFBFBF),
              )
            ],
          ),
        ),
        SizedBox(
          width: 100.sw,
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: 100.sw,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all()),
                    ),
                    Positioned(
                      left: 15,
                      right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: TextWidget(
                                  text: 'Today’s best rate',
                                  color: ColorName.primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: ColorName.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const TextWidget(
                                      text: 'CBE',
                                      fontSize: 8,
                                    ),
                                    const SizedBox(width: 5),
                                    Assets.images.cbeLogo.image(
                                      width: 14,
                                      height: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 100.sw,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage:
                                          Assets.images.usaFlag.provider(),
                                    ),
                                    const SizedBox(width: 7),
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'US Dollar',
                                          fontSize: 9,
                                          weight: FontWeight.w500,
                                          color: ColorName.primaryColor,
                                        ),
                                        TextWidget(
                                          text: '1 USD',
                                          fontSize: 14,
                                          color: ColorName.primaryColor,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: ColorName.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    Assets.images.svgs.exchangeIcon,
                                    // ignore: deprecated_member_use
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage: Assets
                                          .images.ethiopianFlag
                                          .provider(),
                                    ),
                                    const SizedBox(width: 7),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const TextWidget(
                                          text: 'ET Birr',
                                          fontSize: 9,
                                          weight: FontWeight.w500,
                                          color: ColorName.primaryColor,
                                        ),
                                        BlocBuilder<CurrencyBloc,
                                            CurrencyState>(
                                          builder: (context, state) {
                                            if (state is CurrencyLoading) {
                                              return const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 3),
                                                child: CustomShimmer(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  width: 67,
                                                  height: 16,
                                                ),
                                              );
                                            }
                                            if (state is CurrencySuccess) {
                                              return TextWidget(
                                                text:
                                                    '${state.currencies.where((c) => c.currencyCode == 'USD').first.rate.toStringAsFixed(2)} ETB',
                                                fontSize: 14,
                                                color: ColorName.primaryColor,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildBankRates() {
    return Container(
      width: 100.sh,
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: 'Today’s Exchange Rate',
                type: TextType.small,
              ),
              TextButton(
                  onPressed: () {
                    //
                  },
                  child: const TextWidget(
                    text: 'View all',
                    color: ColorName.primaryColor,
                    fontSize: 12,
                  ))
            ],
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
                  fontSize: 14,
                ),
                TextWidget(
                  text: 'Buy',
                  fontSize: 14,
                ),
                TextWidget(
                  text: 'Action',
                  fontSize: 14,
                )
              ],
            ),
          ),
          BlocConsumer<BankCurrencyRateBloc, BankCurrencyRateState>(
            listener: (context, state) {
              if (state is BankCurrencyRateFail) {
                showSnackbar(
                  context,
                  title: 'Error',
                  description: state.reason,
                );
              }
            },
            builder: (context, state) {
              if (state is BankCurrencyRateLoading) {
                return const Column(
                  children: [
                    BankRateShimmer(),
                    BankRateShimmer(),
                    BankRateShimmer(),
                    BankRateShimmer(),
                  ],
                );
              }
              if (state is BankCurrencyRateSuccess) {
                return Column(
                  children: [
                    for (var rate in state.rates)
                      _buildBankTile(
                        bankName: rate.bankName,
                        imagePath: getBankImagePath(rate.bankName),
                        buyingAmount: rate.buyingRate.toString(),
                        tipAmount: rate.incrementPercentage,
                        tipColor: (double.parse(rate.incrementPercentage) >= 0)
                            ? ColorName.green
                            : ColorName.red,
                      ),
                  ],
                );
              }
              return const SizedBox();
            },
          )
        ],
      ),
    );
  }

  _buildMoneyAmount(int amount) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 10),
      child: SizedBox(
        height: 35,
        child: OutlinedButton(
          onPressed: () {
            moneyController.text = '$amount';
          },
          child: TextWidget(
            text: '\$$amount',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  _buildExchangeRate() {
    return SizedBox(
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
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ExchangeRateCard(),
                ExchangeRateCard(),
                ExchangeRateCard(),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
