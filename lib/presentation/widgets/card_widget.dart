import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  const CardWidget({
    super.key,
    required this.child,
    required this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        border: border,
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
