import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/receipt/add_money_receipt.dart';
import 'package:transaction_mobile_app/presentation/widgets/receipt/wallet_receipt_widget.dart';

showWalletReceipt(
  BuildContext context,
  WalletTransactionModel walletTransactionModel,
) {
  if (walletTransactionModel.transactionType == "BANK_TO_WALLET") {
    showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (_) => AddMoneyReceipt(
        walletTransactionModel: walletTransactionModel,
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (_) => WalletReceiptWidget(
        walletTransactionModel: walletTransactionModel,
      ),
    );
  }
}
