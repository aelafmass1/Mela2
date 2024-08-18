import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  const CardWidget({
    super.key,
    required this.child,
    required this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(-2, -2),
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
