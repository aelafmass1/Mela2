import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/borderd_rounded_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet/wallet_bloc.dart';
import 'transfer_app_bar.dart';

class TransferWalletsSection extends StatefulWidget {
  const TransferWalletsSection({super.key, this.onWalletChanged});
  final Function(int selectedWallet)? onWalletChanged;
  @override
  TransferWalletsSectionState createState() => TransferWalletsSectionState();
}

class TransferWalletsSectionState extends State<TransferWalletsSection> {
  int selectedWallet = -1;
  int selectedWalletIndex = -1;
  bool isSummerizing = false;
  final fromWalletKey = GlobalKey<TransferAppBarState>();
  @override
  void initState() {
    final state = context.read<WalletBloc>().state;
    selectedWalletIndex = -1;
    selectedWallet = state.wallets[0].walletId;
    super.initState();
  }

  void setSummerizing() {
    setState(() {
      isSummerizing = !isSummerizing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
  }
}

class TransferToUserSection extends StatefulWidget {
  const TransferToUserSection({super.key, required this.onChangePressed});
  final VoidCallback onChangePressed;
  @override
  State<TransferToUserSection> createState() => _TransferToUserSectionState();
}

class _TransferToUserSectionState extends State<TransferToUserSection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        CardWidget(
            width: size.width,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        const NetworkImage('https://picsum.photos/200'),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: const Text("John Doe"),
                  subtitle: const Text("+1408-010-1010"),
                  trailing: BorderdRoundedButton(
                    text: 'Change',
                    onTap: widget.onChangePressed,
                  ),
                ))),
      ],
    );
  }
}

class TransferToPhoneNumberSection extends StatefulWidget {
  const TransferToPhoneNumberSection({
    super.key,
  });
  @override
  State<TransferToPhoneNumberSection> createState() =>
      _TransferToPhoneNumberSectionState();
}

class _TransferToPhoneNumberSectionState
    extends State<TransferToPhoneNumberSection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        CardWidget(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  SvgPicture.asset(Assets.images.svgs.circularUserIcon),
                  const TextWidget(text: "+1408-010-1010")
                ],
              ),
            )),
      ],
    );
  }
}
