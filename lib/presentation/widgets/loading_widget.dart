import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double? size;
  const LoadingWidget({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 24,
      width: size ?? 24,
      child: CircularProgressIndicator(
        color: color ?? Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}
