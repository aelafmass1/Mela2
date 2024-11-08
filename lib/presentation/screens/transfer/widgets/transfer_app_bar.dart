import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class TransferAppBar extends StatelessWidget {
  const TransferAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      title: const Column(
        children: [
          TextWidget(
            text: '\$18,809',
            fontSize: 15,
            weight: FontWeight.bold,
          ),
          TextWidget(
            text: 'USD Wallet',
            fontSize: 15,
            color: ColorName.grey,
          ),
        ],
      ),
      leading: IconButton(
        icon: SvgPicture.asset(Assets.images.svgs.backArrow),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
