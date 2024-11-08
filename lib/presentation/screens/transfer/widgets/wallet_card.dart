import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';

class WalletCard extends StatelessWidget {
  final String currency;
  final String amount;
  final String flagImage;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.currency,
    required this.amount,
    required this.flagImage,
    required this.isSelected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: SizedBox(
          height: 69,
          child: CardWidget(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            border: Border.all(
                color:
                    isSelected ? ColorName.primaryColor : ColorName.lightBlack),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(flagImage),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: '$currency Wallet',
                        fontSize: 14,
                        weight: FontWeight.w500,
                      ),
                      TextWidget(
                        text: amount,
                        fontSize: 12,
                        color: ColorName.grey,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: ColorName.primaryColor,
                  ),
                if (!isSelected)
                  Icon(
                    Icons.radio_button_unchecked,
                    color: ColorName.grey.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
