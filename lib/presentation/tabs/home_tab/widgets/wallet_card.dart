import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class WalletCard extends StatelessWidget {
  final Color color;
  final double amount;
  final String logo;
  final String walletName;
  final bool showPattern;
  const WalletCard({
    super.key,
    required this.color,
    required this.amount,
    required this.logo,
    required this.walletName,
    required this.showPattern,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            width: 93.sw,
            height: 160,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 23,
                      height: 23,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        logo,
                        package: 'currency_icons',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextWidget(
                      text: walletName,
                      color: Colors.white,
                      fontSize: 14,
                      weight: FontWeight.w400,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 80.sw,
                        child: TextWidget(
                          text: '\$${NumberFormat('#,###.##').format(amount)}',
                          type: TextType.large,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: -10,
            child: Visibility(
              visible: showPattern,
              child: SvgPicture.asset(
                Assets.images.svgs.walletPattern,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }
}
