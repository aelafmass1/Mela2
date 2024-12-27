import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../gen/colors.gen.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  const CustomShimmer(
      {super.key,
      required this.width,
      required this.height,
      this.baseColor,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorName.backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
      ),
    );
  }
}
