import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/presentation/screens/%20money_transfer/components/search_receiver_page.dart';

import '../../../../data/models/contact_status_model.dart';

Future<ContactStatusModel?> showMoneyReceiverSelection(
  BuildContext context,
) async {
  ContactStatusModel? selectedContact;
  await showModalBottomSheet(
    context: context,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    scrollControlDisabledMaxHeightRatio: 1,
    builder: (_) => SearchReceiverPage(
      onSelected: (c) {
        selectedContact = c;
      },
    ),
  );
  return selectedContact;
}
