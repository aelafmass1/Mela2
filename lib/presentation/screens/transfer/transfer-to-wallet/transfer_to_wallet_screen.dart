import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          TransferAppBar(key: fromWalletKey),
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
                  : const TextWidget(
                      text: 'Add Money',
                      color: Colors.white,
                    ),
              onPressed: () {
                // Handle transfer
                if (amountKey.currentState?.validated() == true) {
                  final fromWalletId =
                      fromWalletKey.currentState?.selectedWalletModel?.walletId;
                  final toWalletId = toWaletKey.currentState?.selectedWallet;
                  final amount = double.tryParse(
                      amountKey.currentState?.controller.text ?? '0');
                  final note = noteKey.currentState?.controller.text ?? '';
                  context.read<MoneyTransferBloc>().add(TransferToOwnWallet(
                      fromWalletId: fromWalletId ?? 0,
                      toWalletId: toWalletId ?? 0,
                      amount: amount ?? 0,
                      note: note));
                }
              },
            );
          },
          listener: (BuildContext context, MoneyTransferState state) {
            if (state is MoneyTransferOwnWalletSuccess) {
              context.pushNamed(RouteName.receiptPage2,
                  extra: ReceiverInfo(
                    receiverName: '',
                    receiverPhoneNumber: '',
                    receiverBankName: '',
                    receiverAccountNumber: '',
                    amount: 0,
                    paymentType: '',
                  ));
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
