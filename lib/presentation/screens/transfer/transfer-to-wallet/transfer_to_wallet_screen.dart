import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/transfer-user-search/user_search.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/components/enter_amount_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/components/note_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/components/transfer_to_section.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/components/transfer_app_bar.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import '../../../../core/utils/show_pincode.dart';
import '../components/wallet_card.dart';
import '../components/amount_input.dart';
import '../components/note_input.dart';
import '../components/check_details_section.dart';

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
                  TransferWalletsSection(),
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
            showPincode(context);
          },
        ),
      ),
    );
  }
}
