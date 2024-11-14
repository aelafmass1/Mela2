import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/check-details-bloc/check_details_bloc.dart';
import '../../../../bloc/transfer-rate/transfer_rate_bloc.dart';
import '../../../../config/routing.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../data/models/receiver_info_model.dart';
import '../../../widgets/loading_widget.dart';
import '../components/check_details_section.dart';
import '../components/enter_amount_section.dart';
import '../components/note_section.dart';
import '../components/transfer_app_bar.dart';
import '../components/transfer_to_section.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final amountKey = GlobalKey<EnterAmountSectionState>();
  final noteKey = GlobalKey<NoteSectionState>();
  final toWaletKey = GlobalKey<TransferWalletsSectionState>();
  final fromWalletKey = GlobalKey<TransferAppBarState>();
  final amountController = TextEditingController();

  String selectedCurrency = 'USD';
  double facilityFee = 12.08;
  double bankFee = 94.28;
  bool isNext() {
    final isTransferToSummerizing = toWaletKey.currentState?.isSummerizing;
    final isAmountSummerizing = amountKey.currentState?.isSummerizing;
    if (isTransferToSummerizing == false && isAmountSummerizing == false) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          TransferAppBar(
            key: fromWalletKey,
            onWalletChanged: (fromWalletId) {
              final toWalletId = toWaletKey.currentState?.selectedWallet;
              context.read<TransferRateBloc>().add(FetchTransferRate(
                    fromWalletId: fromWalletId,
                    toWalletId: toWalletId ?? 0,
                  ));
              context.read<CheckDetailsBloc>().add(FetchTransferFeesEvent(
                    fromWalletId: fromWalletId,
                    toWalletId: toWalletId ?? 0,
                  ));
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 14,
                  ),
                  TransferWalletsSection(
                    key: toWaletKey,
                    onWalletChanged: (toWalletId) {
                      final fromWalletId = fromWalletKey
                          .currentState?.selectedWalletModel?.walletId;

                      context.read<TransferRateBloc>().add(FetchTransferRate(
                            fromWalletId: fromWalletId ?? 0,
                            toWalletId: toWalletId ?? 0,
                          ));
                      context
                          .read<CheckDetailsBloc>()
                          .add(FetchTransferFeesEvent(
                            fromWalletId: fromWalletId ?? 0,
                            toWalletId: toWalletId,
                          ));
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  EnterAmountSection(key: amountKey),
                  const SizedBox(
                    height: 24,
                  ),
                  NoteSection(key: noteKey),
                  const SizedBox(
                    height: 24,
                  ),
                  const CheckDetailsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
          builder: (context, state) {
            return ButtonWidget(
              child: state is MoneyTransferLoading
                  ? const LoadingWidget()
                  : TextWidget(
                      text: isNext() ? "Next" : 'Confirm',
                      color: Colors.white,
                      type: TextType.small,
                    ),
              onPressed: () {
                final isAmountValidated = amountKey.currentState?.validated();
                final fromWalletId =
                    fromWalletKey.currentState?.selectedWalletModel?.walletId;
                final toWalletId = toWaletKey.currentState?.selectedWallet;

                context.read<TransferRateBloc>().add(FetchTransferRate(
                      fromWalletId: fromWalletId ?? 0,
                      toWalletId: toWalletId ?? 0,
                    ));
                // Handle transfer
                if (isAmountValidated ?? false) {
                  if (isNext()) {
                    //
                    amountKey.currentState?.setSummerizing();
                    toWaletKey.currentState?.setSummerizing();
                    setState(() {});

                    return;
                  }
                  context.pushNamed(RouteName.pincodeDeligate,
                      extra: (pincode) {
                    context.pop();

                    final amount = double.tryParse(
                        amountKey.currentState?.controller.text ?? '0');
                    final note = noteKey.currentState?.controller.text ?? '';

                    context.read<MoneyTransferBloc>().add(
                          TransferToOwnWallet(
                            fromWalletId: fromWalletId ?? 0,
                            toWalletId: toWalletId ?? 0,
                            amount: amount ?? 0,
                            note: note,
                          ),
                        );
                  });
                }
              },
            );
          },
          listener: (BuildContext context, MoneyTransferState state) {
            if (state is MoneyTransferOwnWalletSuccess) {
              if (state.walletTransactionModel != null) {
                showWalletReceipt(context, state.walletTransactionModel!);
              }
            }
            if (state is MoneyTransferFail) {
              showSnackbar(context, description: state.reason);
            }
          },
        ),
      ),
    );
  }
}
