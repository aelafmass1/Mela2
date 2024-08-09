import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/gen/fonts.gen.dart';

themeData() {
  return ThemeData(
    scaffoldBackgroundColor: ColorName.backgroundColor,
    fontFamily: FontFamily.openSans,
    colorSchemeSeed: ColorName.primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: ColorName.primaryColor),
    textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black,
        ),
        displayLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 25,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        )),
  );
}
