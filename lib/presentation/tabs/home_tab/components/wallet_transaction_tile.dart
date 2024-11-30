import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/core/utils/get_member_contact_info.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';
import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_detail_model.dart';

import '../../../../config/routing.dart';
import '../../../../data/models/wallet_transaction_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class WalletTransactionTile extends StatefulWidget {
  final WalletTransactionDetailModel walletTransaction;
  final List<Contact> contacts;
  const WalletTransactionTile(
      {super.key, required this.walletTransaction, required this.contacts});

  @override
  State<WalletTransactionTile> createState() => _WalletTransactionTileState();
}

class _WalletTransactionTileState extends State<WalletTransactionTile> {
  ContactEqubMember? getUserContactInfo({
    required MelaUser melaUser,
  }) {
    if (melaUser.firstName != null && melaUser.lastName != null) {
      return ContactEqubMember(
          displayName: '${melaUser.firstName} ${melaUser.lastName}',
          phoneNumber: '+${melaUser.countryCode}${melaUser.phoneNumber}');
    }
    return null;
  }

  _getContactName(String phoneNumber) {
    final contact = widget.contacts.where((c) {
      if (c.phones.isEmpty == true) {
        return false;
      }
      return c.phones.first.number == phoneNumber;
    });
    if (contact.isNotEmpty) {
      return contact.first.displayName;
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        minVerticalPadding: 0,
        onTap: () {
          if (widget.walletTransaction.transactionType == 'REMITTANCE') {
            final receiverInfo = ReceiverInfo(
              receiverName: widget.walletTransaction.receiverName ?? '',
              receiverPhoneNumber:
                  widget.walletTransaction.receiverPhoneNumber ?? '',
              receiverBankName: widget.walletTransaction.receiverBank ?? '',
              receiverAccountNumber:
                  widget.walletTransaction.receiverAccountNumber ?? '',
              amount: widget.walletTransaction.amount?.toDouble() ?? 0,
              paymentType: widget.walletTransaction.transactionType,
            );
            context.pushNamed(
              RouteName.receipt,
              extra: receiverInfo,
            );
          } else {
            showWalletReceipt(
              context,
              WalletTransactionModel(
                amount: widget.walletTransaction.amount ?? 0,
                note: widget.walletTransaction.note,
                fromWalletBalance: widget.walletTransaction.convertedAmount,
                fromWalletId:
                    widget.walletTransaction.fromWallet?.walletId ?? 0,
                timestamp: widget.walletTransaction.timestamp,
                toWalletId: widget.walletTransaction.toWallet?.walletId,
                transactionId: widget.walletTransaction.transactionId ?? 0,
                transactionType: widget.walletTransaction.transactionType,
                from:
                    "${widget.walletTransaction.fromWallet?.holder?.firstName} ${widget.walletTransaction.fromWallet?.holder?.lastName}",
                to: widget.walletTransaction.transactionType ==
                        'PENDING_TRANSFER'
                    ? _getContactName(widget.walletTransaction
                            .pendingTransfer?['recipientPhoneNumber'] ??
                        'Unregistered User')
                    : "${widget.walletTransaction.toWallet?.holder?.firstName} ${widget.walletTransaction.toWallet?.holder?.lastName}",
              ),
            );
          }
        },
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: ColorName.primaryColor,
          ),
          child: Center(
            child: Assets.images.profileImage.image(),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextWidget(
              text: DateFormat('hh:mm a')
                  .format(widget.walletTransaction.timestamp.toLocal()),
              fontSize: 10,
              weight: FontWeight.w400,
              color: ColorName.grey,
            ),
            const SizedBox(height: 5),
            TextWidget(
              text:
                  '+\$${NumberFormat('##,###.##').format(widget.walletTransaction.amount)}',
              fontSize: 16,
              weight: FontWeight.w700,
              color: ColorName.green,
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.walletTransaction.transactionType == 'PENDING_TRANSFER')
              TextWidget(
                text: _getContactName(widget.walletTransaction
                        .pendingTransfer?['recipientPhoneNumber'] ??
                    'Unregistered User'),
                fontSize: 16,
                weight: FontWeight.w500,
              )
            else if (widget.walletTransaction.transactionType ==
                    'WALLET_TO_WALLET' ||
                widget.walletTransaction.transactionType == 'BANK_TO_WALLET')
              if (widget.walletTransaction.transactionType ==
                      'WALLET_TO_WALLET' &&
                  widget.walletTransaction.toWallet?.holder != null)
                TextWidget(
                  text: getUserContactInfo(
                        melaUser: widget.walletTransaction.toWallet?.holder ??
                            MelaUser(
                              phoneNumber: 0,
                              countryCode: 1,
                            ),
                      )?.displayName ??
                      "${widget.walletTransaction.toWallet?.holder?.firstName ?? widget.walletTransaction.receiverName ?? 'Unregistered User'} ${widget.walletTransaction.toWallet?.holder?.lastName ?? ''}",
                  fontSize: 16,
                  weight: FontWeight.w500,
                )
              else
                const TextWidget(
                  text: "You",
                  fontSize: 16,
                  weight: FontWeight.w500,
                )
            else
              TextWidget(
                text: getUserContactInfo(
                      melaUser: widget.walletTransaction.toWallet?.holder ??
                          MelaUser(
                            phoneNumber: 0,
                            countryCode: 1,
                          ),
                    )?.displayName ??
                    "${widget.walletTransaction.toWallet?.holder?.firstName ?? widget.walletTransaction.receiverName ?? 'Unregistered User'} ${widget.walletTransaction.toWallet?.holder?.lastName ?? ''}",
                fontSize: 16,
                weight: FontWeight.w500,
              ),
          ],
        ),
        subtitle: TextWidget(
          text: widget.walletTransaction.transactionType,
          fontSize: 10,
          weight: FontWeight.w400,
        ),
      ),
    );
  }
}
