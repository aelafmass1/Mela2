import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_recent_transaction/wallet_recent_transaction_bloc.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';

import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class RecentMembers extends StatefulWidget {
  const RecentMembers({super.key});

  @override
  State<RecentMembers> createState() => _RecentMembersState();
}

class _RecentMembersState extends State<RecentMembers> {
  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Visibility(
        visible: isEmpty == false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextWidget(
                  text: 'Recent',
                  type: TextType.small,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton.outlined(
                      color: ColorName.grey,
                      onPressed: () {
                        //
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                    const TextWidget(
                      text: 'Send',
                      fontSize: 8,
                      weight: FontWeight.w400,
                    )
                  ],
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: BlocConsumer<WalletRecentTransactionBloc,
                        WalletRecentTransactionState>(
                      listener: (context, state) {
                        if (state is WalletRecentTransactionSuccess) {
                          log(state.transactions.toString());
                          if (state.transactions.isEmpty) {
                            setState(() {
                              isEmpty = true;
                            });
                          }
                        }
                      },
                      builder: (context, state) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (state is WalletRecentTransactionLoading)
                              ...List.generate(
                                  6,
                                  (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          children: [
                                            CustomShimmer(
                                              width: 40,
                                              height: 40,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            const SizedBox(height: 5),
                                            const CustomShimmer(
                                              width: 30,
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ))
                            else if (state is WalletRecentTransactionSuccess)
                              for (int index = 0;
                                  index < state.transactions.length;
                                  index++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 15),
                                      Stack(
                                        children: [
                                          Container(
                                            width: 39,
                                            height: 39,
                                            margin: const EdgeInsets.only(
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: ColorName
                                                  .primaryColor.shade100,
                                            ),
                                            child: Center(
                                              child: TextWidget(
                                                text:
                                                    '${state.transactions[index].holder?.firstName?.substring(0, 1) ?? ''}${state.transactions[index].holder?.lastName?.substring(0, 1) ?? ''}',
                                                type: TextType.small,
                                                color: ColorName.white,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              bottom: 2,
                                              child: Container(
                                                width: 15,
                                                height: 15,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.amber,
                                                ),
                                                child: Image.asset(
                                                  'icons/currency/${state.transactions[index].currency.code.toLowerCase()}.png',
                                                  package: 'currency_icons',
                                                  fit: BoxFit.cover,
                                                ),
                                              ))
                                        ],
                                      ),
                                      TextWidget(
                                        text: state.transactions[index].holder
                                                ?.firstName ??
                                            '',
                                        fontSize: 8,
                                        weight: FontWeight.w400,
                                        color: ColorName.grey,
                                      ),
                                      TextWidget(
                                        text:
                                            '${state.transactions[index].balance ?? ''}',
                                        fontSize: 8,
                                        weight: FontWeight.w700,
                                      )
                                    ],
                                  ),
                                )
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
