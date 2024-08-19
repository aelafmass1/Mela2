import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/currency_rate/currency_rate_bloc.dart';
import 'package:transaction_mobile_app/core/utils/bank_image.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  getToken() async {
    final res = await FirebaseAuth.instance.currentUser!.getIdToken();
    log(res.toString());
  }

  @override
  void initState() {
    getToken();
    log(FirebaseAuth.instance.currentUser.toString());
    context.read<CurrencyRateBloc>().add(FetchCurrencyRate());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: 'Good Morning',
                      fontSize: 14,
                    ),
                    const TextWidget(
                      text: 'Amanuel',
                      fontSize: 24,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'enter Money amount',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                        ),
                        prefixIcon: Assets.images.dollar.image(
                          height: 25,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: ButtonWidget(
                      borderRadius: BorderRadius.circular(10),
                      child: const TextWidget(
                        text: 'Send',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  width: 100.sh,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    border: Border.all(
                      color: const Color(0xFF4D4D4D).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextWidget(
                          text: 'Today’s  Exchange Rate',
                          fontSize: 14,
                          color: const Color(0xFF4D4D4D).withOpacity(0.7),
                        ),
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
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            ),
                            TextWidget(
                              text: 'Buying (ETB)',
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            ),
                            TextWidget(
                              text: 'Action',
                              color: Color(0xFF4D4D4D),
                              fontSize: 15,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<CurrencyRateBloc, CurrencyRateState>(
                          builder: (context, state) {
                            if (state is CurrencyRateLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is CurrencyRateSuccess) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  context
                                      .read<CurrencyRateBloc>()
                                      .add(FetchCurrencyRate());
                                },
                                child: ListView.builder(
                                  itemCount: state.rates.length,
                                  itemBuilder: (context, index) =>
                                      _buildBankTile(
                                    bankName: state.rates[index].bankName,
                                    imagePath: getBankImagePath(
                                        state.rates[index].bankName),
                                    buyingAmount: state.rates[index].buyingRate
                                        .toString(),
                                    tipAmount:
                                        state.rates[index].incrementPercentage,
                                    tipColor: (double.parse(state.rates[index]
                                                .incrementPercentage) >=
                                            0)
                                        ? ColorName.green
                                        : ColorName.red,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: 45,
                    height: 45,
                  ),
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: bankName,
                  fontSize: 10,
                  color: const Color(0xFF4D4D4D),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: TextWidget(
                  text: buyingAmount,
                  fontSize: 13,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: TextWidget(
                  text: '$tipAmount %',
                  color: tipColor ?? ColorName.red,
                  fontSize: 7,
                ),
              )
            ],
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
                shape: ContinuousRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: ColorName.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                //
              },
              child: const TextWidget(
                text: 'Send',
                type: TextType.small,
                color: ColorName.borderColor,
              ))
        ],
      ),
    );
  }
}
