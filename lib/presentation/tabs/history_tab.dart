import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_transaction/wallet_transaction_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_detail_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../core/utils/show_wallet_receipt.dart';
import '../../data/models/receiver_info_model.dart';
import '../../data/models/wallet_transaction_model.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String selectedFilter = 'all';

  _fetchContacts() async {
    try {
      if (await Permission.contacts.isGranted) {
        if (mounted) context.read<ContactBloc>().add(FetchContacts());
      } else {
        await Permission.contacts.request();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  _getContactName(
      WalletTransactionDetailModel transaction, Map<int, String> contacts) {
    debugPrint("contacts: ${transaction.toWallet?.holder!.id}");
    if (transaction.transactionType == 'BANK_TO_WALLET') {
      return "You";
    } else if (transaction.transactionType == 'REMITTANCE') {
      return transaction.receiverName ?? transaction.receiverPhoneNumber ?? "_";
    }
    return transaction.toWallet == null
        ? 'Unregistered User'
        : contacts[transaction.toWallet!.holder!.id] ??
            '${transaction.toWallet?.holder?.firstName ?? ''} ${transaction.toWallet?.holder?.lastName ?? ''}';
  }

  @override
  void initState() {
    final state = context.read<WalletTransactionBloc>().state;

    if (state is! WalletTransactionSuccess) {
      _fetchContacts();
    }

    final contactState = context.read<ContactBloc>().state;
    if (contactState is ContactInitial) {}
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 50,
        title: const TextWidget(
          text: 'Transaction History',
          fontSize: 20,
          weight: FontWeight.w700,
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     //
          //   },
          //   icon: const Icon(Icons.print_outlined),
          // ),
          IconButton(
            onPressed: () {
              //
            },
            icon: SvgPicture.asset(Assets.images.svgs.filterIcon),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: selectedFilter == 'all'
                              ? ColorName.primaryColor
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: selectedFilter == 'all'
                                ? BorderSide.none
                                : const BorderSide(),
                          ),
                        ),
                        child: TextWidget(
                          text: 'All',
                          fontSize: 12,
                          color: selectedFilter == 'all' ? Colors.white : null,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'all';
                          });
                        }),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: selectedFilter == 'remittance'
                              ? ColorName.primaryColor
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: selectedFilter == 'remittance'
                                ? BorderSide.none
                                : const BorderSide(),
                          ),
                        ),
                        child: TextWidget(
                          text: 'Remittance',
                          fontSize: 12,
                          color: selectedFilter == 'remittance'
                              ? Colors.white
                              : null,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'remittance';
                          });
                        }),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: ColorName.borderColor,
              ),
            ),
            BlocConsumer<WalletTransactionBloc, WalletTransactionState>(
              listener: (context, state) {
                if (state is WalletTransactionFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                }
              },
              builder: (context, state) {
                if (state is WalletTransactionLoading) {
                  return const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: LoadingWidget(
                        color: ColorName.primaryColor,
                      ),
                    ),
                  );
                } else if (state is WalletTransactionSuccess) {
                  if (state.walletTransactions.isNotEmpty) {
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<WalletTransactionBloc>()
                              .add(FetchWalletTransaction());
                        },
                        child: ListView.separated(
                            separatorBuilder: (context, index) => const Divider(
                                  color: ColorName.borderColor,
                                ),
                            itemCount: state.walletTransactions.length,
                            itemBuilder: (context, index) {
                              var key = state.walletTransactions.keys
                                  .elementAt(index);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now()) ==
                                            key
                                        ? 'Today'
                                        : (DateTime.parse(key).day - 1) ==
                                                DateTime.now().day
                                            ? 'Yesterday'
                                            : DateFormat('d-MMMM yyyy')
                                                .format(DateTime.parse(key)),
                                    color: ColorName.primaryColor,
                                    fontSize: 14,
                                    weight: FontWeight.w600,
                                  ),
                                  for (var transaction
                                      in state.walletTransactions[key]!)
                                    _buildTrasactionTile(transaction),
                                ],
                              );
                            }),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 30),
                      Assets.images.noTransaction.image(
                        width: 350,
                        height: 350,
                      ),
                      const TextWidget(
                        text: 'oops, You don’t have any History.',
                        weight: FontWeight.w600,
                        fontSize: 16,
                      )
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }

  _buildTrasactionTile(WalletTransactionDetailModel transaction) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        return ListTile(
          onTap: () {
            if (transaction.transactionType == 'REMITTANCE') {
              final receiverInfo = ReceiverInfo(
                receiverName:
                    _getContactName(transaction, state.remoteContacts),
                receiverPhoneNumber: transaction.receiverPhoneNumber ?? '',
                receiverBankName: transaction.receiverBank ?? '',
                receiverAccountNumber: transaction.receiverAccountNumber ?? '',
                amount: transaction.amount?.toDouble() ?? 0,
                paymentType: transaction.transactionType,
              );
              context.pushNamed(
                RouteName.receipt,
                extra: receiverInfo,
              );
            } else {
              showWalletReceipt(
                context,
                WalletTransactionModel(
                  amount: transaction.amount ?? 0,
                  note: transaction.note,
                  fromWalletBalance: transaction.convertedAmount,
                  fromWalletId: transaction.fromWallet?.walletId ?? 0,
                  timestamp: transaction.timestamp,
                  toWalletId: transaction.toWallet?.walletId,
                  transactionId: transaction.transactionId ?? 0,
                  transactionType: transaction.transactionType,
                  from:
                      "${transaction.fromWallet?.holder?.firstName} ${transaction.fromWallet?.holder?.lastName}",
                  to: _getContactName(transaction, state.remoteContacts),
                ),
              );
            }
          },
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: const Color(0xFFA000C8).withOpacity(0.1),
            ),
            child: Center(
              child: SvgPicture.asset(
                Assets.images.svgs.transactionIcon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(
                text: '\$${transaction.amount}',
                fontSize: 14,
                weight: FontWeight.w600,
              ),
              TextWidget(
                text: DateFormat('hh:mm a')
                    .format(transaction.timestamp.toLocal()),
                fontSize: 10,
                weight: FontWeight.w400,
              )
            ],
          ),
          title: TextWidget(
            text: _getContactName(transaction, state.remoteContacts),
            fontSize: 14,
            weight: FontWeight.w400,
          ),
          subtitle: TextWidget(
            text: transaction.receiverPhoneNumber ??
                (transaction.toWallet == null
                    ? '${transaction.pendingTransfer?['recipientPhoneNumber'] ?? ''}'
                    : ("+${transaction.toWallet?.holder?.countryCode ?? ''} ${transaction.toWallet?.holder?.phoneNumber ?? ''}")),
            fontSize: 10,
            weight: FontWeight.w400,
          ),
        );
      },
    );
  }
}
