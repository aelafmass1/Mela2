import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/core/utils/date_formater.dart';
import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/core/utils/get_status_details.dart';
import 'package:transaction_mobile_app/presentation/widgets/wallet_receipt_widget.dart';

showWalletReceipt(
    BuildContext context, WalletTransactionModel walletTransactionModel,
    {Map<int, String>? contacts, List<ContactStatusModel>? localContacs}) {
  List<List<String>> contents = [];

  String amount = '\$${walletTransactionModel.amount}';

  String message = "";

  if (walletTransactionModel.transactionType == "BANK_TO_WALLET") {
    contents = [
      ["Transaction Type", walletTransactionModel.transactionType],
      ["From", walletTransactionModel.from],
      ["Amount", walletTransactionModel.amount.toString()],
      ["Date", formatDate(walletTransactionModel.timestamp)],
      ["Transaction ID", walletTransactionModel.transactionId.toString()],
      [
        "Transaction Status",
        getStatusDetails(
            walletTransactionModel.status ?? "SUCCESS")['normalizedText']
      ],
      [
        "Remark",
        (walletTransactionModel.note?.length ?? 0) > 20
            ? '${walletTransactionModel.note!.substring(0, 20)}...'
            : walletTransactionModel.note ?? ''
      ],
    ];

    message =
        'Money has been successfully added to ${walletTransactionModel.fromWallet?.currency.code ?? 'your'} wallet.';
  } else {
    contents = [
      [
        "To",
        walletTransactionModel.to(contacts ?? {}, localContacts: localContacs)
      ],
      ["Amount", walletTransactionModel.amount.toString()],
      ["Date", formatDate(walletTransactionModel.timestamp)],
      ["Transaction ID", walletTransactionModel.transactionId.toString()],
      ["Details", walletTransactionModel.transactionType],
      [
        "Transaction Status",
        getStatusDetails(
            walletTransactionModel.status ?? "SUCCESS")['normalizedText']
      ],
      [
        "Remark",
        (walletTransactionModel.note?.length ?? 0) > 20
            ? '${walletTransactionModel.note!.substring(0, 20)}...'
            : walletTransactionModel.note ?? ''
      ],
    ];
    amount = '-\$${walletTransactionModel.amount}';
    message =
        'Money has been successfully transfered from ${walletTransactionModel.fromWallet?.currency.code ?? 'your'} wallet.';
  }
  showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 1,
    builder: (_) => WalletReceiptWidget(
      walletTransactionModel: walletTransactionModel,
      contents: contents,
      amount: amount,
      message: message,
    ),
  );
}
