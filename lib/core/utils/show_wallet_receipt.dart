import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/wallet_receipt_widget.dart';

showWalletReceipt(
  BuildContext context,
  WalletTransactionModel walletTransactionModel,
) {
  showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 1,
    builder: (_) => WalletReceiptWidget(
      walletTransactionModel: walletTransactionModel,
    ),
  );
}
