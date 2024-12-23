import 'package:flutter/material.dart';

import '../../core/utils/ui_helpers.dart';
import '../../gen/colors.gen.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    // this.onTap,
    this.leading,
    this.title,
    this.subtitle,
    this.trailingWidget,
  });
  // final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: onTap,
      child: Container(
        width: screenWidth(context),
        padding: const EdgeInsets.symmetric(
            horizontal: smallSize, vertical: tinySize),
        decoration: const BoxDecoration(
          color: ColorName.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(middleSize)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                verticalSpaceSmall,
                leading ?? emptySpace,
              ],
            ),
            horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title ?? emptySpace,
                  verticalSpaceSmall,
                  subtitle ?? emptySpace,
                ],
              ),
            ),
            trailingWidget ?? emptySpace, // Add trailing widget
          ],
        ),
      ),
    );
  }
}
