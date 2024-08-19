import 'package:flutter/material.dart';

import '../../gen/colors.gen.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String? text)? validator;
  final Widget? suffix;
  final Function()? onTab;
  final TextInputType? keyboardType;
  final bool readOnly;
  const TextFieldWidget(
      {super.key,
      required this.controller,
      this.validator,
      this.hintText,
      this.suffix,
      this.onTab,
      this.keyboardType,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTab,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      cursorColor: ColorName.primaryColor,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E8E),
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: ColorName.primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
