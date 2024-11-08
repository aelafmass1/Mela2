import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/transfer/components/wallet_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/borderd_rounded_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class TransferWalletsSection extends StatefulWidget {
  const TransferWalletsSection({super.key});

  @override
  State<TransferWalletsSection> createState() => _TransferWalletsSectionState();
}

class _TransferWalletsSectionState extends State<TransferWalletsSection> {
  int selectedWallet = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Transfer To',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 14),
        ...List.generate(
          3,
          (index) {
            final isSelected = index == selectedWallet;
            return WalletCard(
              padding: const EdgeInsets.symmetric(vertical: 5),
              currency: 'USD',
              amount: '\$18,809',
              flagImage: Assets.images.usaFlag.path,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  selectedWallet = index;
                });
              },
            );
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorName.primaryColor,
                backgroundColor: Colors.white,
                elevation: 7,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    TextWidget(
                      text: 'Add New Card',
                      color: ColorName.primaryColor,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
