import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

class BorderdRoundedButton extends StatelessWidget {
  const BorderdRoundedButton({
    super.key,
    required this.text,
    required this.onTap,
  });
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorName.primaryColor,
        side: const BorderSide(color: ColorName.primaryColor),
      ),
      child: const Text('Change'),
    );
  }
}
