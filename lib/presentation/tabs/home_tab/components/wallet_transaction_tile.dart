import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';
import 'package:transaction_mobile_app/core/utils/contact_utils.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';

import '../../../../data/models/wallet_transaction_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class WalletTransactionTile extends StatefulWidget {
  final WalletTransactionModel walletTransaction;
  final List<Contact> contacts;
  const WalletTransactionTile(
      {super.key, required this.walletTransaction, required this.contacts});

  @override
  State<WalletTransactionTile> createState() => _WalletTransactionTileState();
}

class _WalletTransactionTileState extends State<WalletTransactionTile> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
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
              showWalletReceipt(context, widget.walletTransaction,
                  contacts: state.remoteContacts,
                  localContacs: state.localContacs);
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
                TextWidget(
                  text: widget.walletTransaction.to(state.remoteContacts,
                      localContacts: state.localContacs),
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
      },
    );
  }
}
