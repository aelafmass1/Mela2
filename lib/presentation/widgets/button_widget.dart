import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../core/utils/responsive_util.dart';

class ButtonWidget extends StatelessWidget {
  final Widget child;
  final Function() onPressed;
  final double? topPadding;
  final BorderRadius? borderRadius;
  const ButtonWidget(
      {super.key,
      required this.child,
      required this.onPressed,
      this.borderRadius,
      this.topPadding});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding ?? 0),
        child: SizedBox(
          width: ResponsiveUtil.forScreen(
              sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                )),
            onPressed: onPressed,
            child: child,
          ),
        ),
      );
    });
  }
}
