import 'package:flutter/material.dart';

enum TextType {
  small,
  midium,
  large,
}

class TextWidget extends StatelessWidget {
  final String text;
  final TextType type;
  final Color? color;
  final FontWeight? weight;
  final double? fontSize;
  final TextAlign? textAlign;
  const TextWidget({
    super.key,
    required this.text,
    this.type = TextType.midium,
    this.color,
    this.weight,
    this.textAlign,
    this.fontSize,
  });

  double _getFontType(TextType type) {
    if (type == TextType.small) {
      return 16;
    } else if (type == TextType.midium) {
      return 20;
    } else if (type == TextType.large) {
      return 32;
    }
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize ?? _getFontType(type),
          color: color ?? Colors.black,
          fontWeight: weight ?? FontWeight.w500,
        ),
      ),
    );
  }
}
