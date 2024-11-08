import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../data/models/wallet_model.dart';
import '../../presentation/widgets/wallet_selection_widget.dart';

Future<WalletModel?> showChangeWalletModal(
    {required BuildContext context}) async {
  WalletModel? selectedWallet;
  await showModalBottomSheet<WalletModel>(
    context: context,
    scrollControlDisabledMaxHeightRatio: 70.sh,
    backgroundColor: Colors.white,
    builder: (context) => WalletSelectionWidget(
      onSelect: (s) {
        log('selected Wallet');
        selectedWallet = s;
      },
    ),
  );
  return selectedWallet;
}
