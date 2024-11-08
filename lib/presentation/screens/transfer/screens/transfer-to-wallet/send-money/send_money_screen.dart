import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/widgets/enter_amount_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/widgets/note_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/widgets/transfer_to_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/widgets/transfer_app_bar.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import '../../../widgets/wallet_card.dart';
import '../../../widgets/amount_input.dart';
import '../../../widgets/note_input.dart';
import '../../../widgets/check_details_section.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final amountKey = GlobalKey<FormFieldState>();
  final noteKey = GlobalKey<FormFieldState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String selectedCurrency = 'USD';
  double facilityFee = 12.08;
  double bankFee = 94.28;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CustomScrollView(
        slivers: [
          TransferAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                  ),
                  TransferToWalletSection(),
                  SizedBox(
                    height: 24,
                  ),
                  EnterAmountSection(),
                  SizedBox(
                    height: 24,
                  ),
                  NoteSection(),
                  SizedBox(
                    height: 24,
                  ),
                  CheckDetailsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ButtonWidget(
          child: const TextWidget(
            text: 'Add Money',
            color: Colors.white,
          ),
          onPressed: () {
            // Handle transfer
          },
        ),
      ),
    );
  }
}
