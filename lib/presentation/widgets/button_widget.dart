import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../core/utils/responsive_util.dart';

class ButtonWidget extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;
  final double? topPadding;
  final BorderRadius? borderRadius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Color? color;
  final BorderSide borderSide;
  final double? elevation;

  const ButtonWidget({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius,
    this.topPadding,
    this.verticalPadding,
    this.color,
    this.borderSide = BorderSide.none,
    this.horizontalPadding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding ?? 0),
        child: SizedBox(
          height: 55,
          width: ResponsiveUtil.forScreen(
              sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: elevation,
                backgroundColor: color ?? ColorName.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding ?? 13,
                    horizontal: horizontalPadding ?? 0),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(30),
                  side: borderSide,
                )),
            onPressed: onPressed,
            child: child,
          ),
        ),
      );
    });
  }
}
