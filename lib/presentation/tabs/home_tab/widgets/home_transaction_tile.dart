import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/core/utils/get_member_contact_info.dart';
import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_detail_model.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class HomeTransactionTile extends StatefulWidget {
  final WalletTransactionDetailModel walletTransaction;
  const HomeTransactionTile({super.key, required this.walletTransaction});

  @override
  State<HomeTransactionTile> createState() => _HomeTransactionTileState();
}

class _HomeTransactionTileState extends State<HomeTransactionTile> {
  List<Contact> contacts = [];

  Future<void> _fetchContacts() async {
    if (kIsWeb) return;

    if (await FlutterContacts.requestPermission(readonly: true)) {
      if (contacts.isEmpty) {
        List<Contact> c =
            await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          contacts = c;
        });
      }
    }
  }

  Future<ContactEqubMember?> getUserContactInfo({
    required MelaUser melaUser,
  }) async {
    await _fetchContacts();
    final phoneN = await removeCountryCode(
        '+${melaUser.countryCode}${melaUser.phoneNumber}');

    if (phoneN == null) {
      return null;
    }

    final user = contacts
        .where((c) => c.phones.first.number
            .replaceAll(RegExp(r'\s+'), '')
            .endsWith(phoneN))
        .toList();
    if (user.isNotEmpty) {
      final phoneNumber = user.first.phones.first.number;
      final userName = user.first.displayName;
      return ContactEqubMember(displayName: userName, phoneNumber: phoneNumber);
    }
    if (melaUser.firstName != null && melaUser.lastName != null) {
      return ContactEqubMember(
          displayName: '${melaUser.firstName} ${melaUser.lastName}',
          phoneNumber: '+${melaUser.countryCode}${melaUser.phoneNumber}');
    }
    return null;
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
          //
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
                  .format(widget.walletTransaction.timestamp),
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
            if (widget.walletTransaction.transactionType ==
                    'WALLET_TO_WALLET' ||
                widget.walletTransaction.transactionType == 'BANK_TO_WALLET')
              const TextWidget(
                text: "You",
                fontSize: 16,
                weight: FontWeight.w500,
              )
            else
              FutureBuilder(
                  future: getUserContactInfo(
                    melaUser: widget.walletTransaction.toUser ??
                        MelaUser(
                          phoneNumber: 0,
                          countryCode: 1,
                        ),
                  ),
                  builder: (context, snapshot) {
                    return TextWidget(
                      text: snapshot.data?.displayName ??
                          "${widget.walletTransaction.toUser?.firstName ?? 'Unknown'} ${widget.walletTransaction.toUser?.lastName ?? 'User'}",
                      fontSize: 16,
                      weight: FontWeight.w500,
                    );
                  }),
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
