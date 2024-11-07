import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class WalletOptions extends StatelessWidget {
  const WalletOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOptionButton(
            iconPath: Assets.images.svgs.addMoney,
            title: 'Add Money',
            onTab: () {
              context.pushNamed(RouteName.addMoney);
            },
          ),
          _buildOptionButton(
            iconPath: Assets.images.svgs.sendIcon,
            iconColor: Colors.black,
            title: 'Transfer',
            onTab: () {
              // TODO
            },
          ),
          _buildOptionButton(
            iconPath: Assets.images.svgs.requestLogo,
            title: 'Request',
            onTab: () {
              // TODO
            },
          ),
          _buildOptionButton(
            iconPath: Assets.images.svgs.withdrawLogo,
            title: 'Withdraw',
            onTab: () {
              // TODO
            },
          ),
        ],
      ),
    );
  }

  _buildOptionButton({
    required String iconPath,
    required String title,
    required Function() onTab,
    Color? iconColor,
  }) {
    return SizedBox(
      width: 85,
      height: 68,
      child: ButtonWidget(
        borderRadius: BorderRadius.circular(10),
        elevation: 0,
        color: const Color(0xFFF5F5F5),
        onPressed: onTab,
        child: Column(
          children: [
            // ignore: deprecated_member_use
            SvgPicture.asset(iconPath, width: 18, height: 18, color: iconColor),
            const SizedBox(height: 5),
            TextWidget(
              text: title,
              fontSize: 10,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
