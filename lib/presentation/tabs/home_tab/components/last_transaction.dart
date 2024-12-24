import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/wallet_transaction_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';

import '../../../../bloc/wallet_transaction/wallet_transaction_bloc.dart';
import '../../../widgets/text_widget.dart';

class LastTransaction extends StatefulWidget {
  const LastTransaction({
    super.key,
  });

  @override
  State<LastTransaction> createState() => _LastTransactionState();
}

class _LastTransactionState extends State<LastTransaction> {
  String? selectedDayFilter;
  List<WalletTransactionModel> selectedWallets = [];
  bool showThisPage = true;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contacts.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showThisPage,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 100.sw,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: 'Last Transaction',
                      type: TextType.small,
                      weight: FontWeight.w600,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: BlocConsumer<WalletTransactionBloc,
                          WalletTransactionState>(
                        listener: (context, state) {
                          if (state is WalletTransactionSuccess) {
                            if (state.walletTransactions.isNotEmpty) {
                              // Convert map entries to a sorted list
                              var sortedEntries =
                                  state.walletTransactions.entries.toList()
                                    ..sort((a, b) => DateTime.parse(b.key)
                                        .compareTo(DateTime.parse(a.key)));
                              // Create a new sorted map from the sorted entries
                              var sortedTransactions =
                                  Map.fromEntries(sortedEntries);
                              setState(() {
                                selectedDayFilter =
                                    sortedTransactions.keys.first;
                                selectedWallets = state.walletTransactions[
                                        selectedDayFilter] ??
                                    [];
                              });
                            } else {
                              setState(() {
                                showThisPage = false;
                              });
                            }
                          } else if (state is WalletTransactionFail) {
                            showSnackbar(
                              context,
                              description: state.reason,
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is WalletTransactionSuccess) {
                            if (state.walletTransactions.isEmpty) {
                              return const SizedBox(
                                width: 50,
                                height: 23,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: TextWidget(
                                      text: '---',
                                      type: TextType.small,
                                      weight: FontWeight.w300,
                                    )),
                              );
                            }
                            return FutureBuilder(
                              future:
                                  Future.delayed(const Duration(seconds: 1)),
                              builder: (_, __) => DropdownButton(
                                  dropdownColor: Colors.white,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  elevation: 0,
                                  alignment: Alignment.center,
                                  value: selectedDayFilter,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  items: [
                                    for (var entery
                                        in state.walletTransactions.keys)
                                      DropdownMenuItem(
                                        value: entery,
                                        alignment: Alignment.center,
                                        child: TextWidget(
                                          text: DateFormat('yyyy-MM-dd')
                                                      .format(DateTime.now()) ==
                                                  entery
                                              ? 'Today'
                                              : (DateTime.now().day - 1) ==
                                                      DateTime.parse(entery).day
                                                  ? 'Yesterday'
                                                  : DateFormat('d-MMMM').format(
                                                      DateTime.parse(entery)),
                                          color: ColorName.primaryColor,
                                          fontSize: 14,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDayFilter = value ?? 'today';
                                      selectedWallets =
                                          state.walletTransactions[value] ?? [];
                                    });
                                  }),
                            );
                          }
                          return const SizedBox(
                            width: 50,
                            height: 23,
                            child: Align(
                                alignment: Alignment.center,
                                child: TextWidget(
                                  text: '---',
                                  type: TextType.small,
                                  weight: FontWeight.w300,
                                )),
                          );
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                  builder: (context, state) {
                    if (state is WalletTransactionLoading) {
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          CustomShimmer(width: 100.sw, height: 55),
                          const SizedBox(height: 10),
                          CustomShimmer(width: 100.sw, height: 55),
                          const SizedBox(height: 10),
                          CustomShimmer(width: 100.sw, height: 55),
                          const SizedBox(height: 10),
                          CustomShimmer(width: 100.sw, height: 55),
                        ],
                      );
                    } else if (state is WalletTransactionSuccess) {
                      if (state.walletTransactions.isEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          child: const TextWidget(
                            text: 'No Recent Transaction History',
                            fontSize: 15,
                            weight: FontWeight.w300,
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var transaction in selectedWallets)
                              WalletTransactionTile(
                                contacts: contacts,
                                walletTransaction: transaction,
                              ),
                          ],
                        );
                      }
                    }
                    return const SizedBox();
                  },
                )
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 20,
              child: Align(
                child: Container(
                  width: 80,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorName.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
