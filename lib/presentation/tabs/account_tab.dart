import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 5),
            child: ResponsiveBuilder(builder: (context, sizingInfo) {
              return CircleAvatar(
                radius: ResponsiveUtil.forScreen(
                  sizingInfo: sizingInfo,
                  mobile: 50,
                  tablet: 80,
                ),
                backgroundImage: Assets.images.profileImage.provider(),
              );
            }),
          ),
          const TextWidget(text: 'Samuel Alebachew'),
          TextWidget(
            text: 'Customer',
            fontSize: 15,
            color: const Color(0xFF4D4D4D).withOpacity(0.75),
          ),
          const SizedBox(height: 20),
          // _buildTab(
          //   icon: Icons.person_outline,
          //   title: 'Personal Information',
          //   onTab: () {
          //     //
          //   },
          // ),
          // _buildTab(
          //   icon: Icons.settings_outlined,
          //   title: 'Account Setting',
          //   onTab: () {
          //     //
          //   },
          // ),
          // _buildTab(
          //   icon: Icons.lock_outlined,
          //   title: 'Security Setting',
          //   onTab: () {
          //     //
          //   },
          // ),
          // _buildTab(
          //   icon: Icons.edit_outlined,
          //   title: 'Edit Account',
          //   onTab: () {
          //     //
          //   },
          // ),
          _buildTab(
            icon: Icons.logout,
            title: 'Logout',
            isLogout: true,
            onTab: () {
              context.goNamed(RouteName.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      {required IconData icon,
      required String title,
      required Function() onTab,
      bool isLogout = false}) {
    return GestureDetector(
      onTap: onTab,
      child: ResponsiveBuilder(builder: (context, sizingInfo) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: ResponsiveUtil.forScreen(
              sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isLogout ? ColorName.red : Colors.black,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
              ),
              const SizedBox(width: 10),
              TextWidget(
                text: title,
                fontSize: 15,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
                weight: FontWeight.w400,
              ),
              const Expanded(child: SizedBox()),
              Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
              )
            ],
          ),
        );
      }),
    );
  }
}
