import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

// Size constants for UI elements
const double veryTinySize = 2.0;
const double tinySize = 5.0;
const double smallSize = 10.0;
const double middleSize = 15.0;
const double mediume20 = 20.0;
const double mediumSize = 25.0;
const double largeSize = 50.0;
const double largeMedium = 72.0;
const double massiveSize = 120.0;
const double customButtonWidth = 0.85;

bool isAndroid = Platform.isAndroid;
bool isIos = Platform.isIOS;

// An empty widget that takes no space
const Widget emptySpace = SizedBox.shrink();

// horizontal spaces
const Widget horizontalSpaceTiny = SizedBox(width: tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: smallSize);
const Widget horizontalSpaceMiddle = SizedBox(width: middleSize);
const Widget horizontalSpaceMedium = SizedBox(width: mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: largeSize);

// dynamic horizontal space
Widget horizontalSpace(double height) => SizedBox(height: height);

// vertical spaces
const Widget verticalSpaceTiny = SizedBox(height: tinySize);
const Widget verticalSpaceSmall = SizedBox(height: smallSize);
const Widget verticalSpaceMiddle = SizedBox(height: middleSize);
const Widget verticalSpaceMedium = SizedBox(height: mediumSize);
const Widget verticalSpaceLarge = SizedBox(height: largeSize);
const Widget verticalSpaceMassive = SizedBox(height: massiveSize);

// dynamic vertical space
Widget verticalSpace(double height) => SizedBox(height: height);

// screen size based on device
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    // Returns a fraction of the screen height based on the dividedBy and offsetBy parameters.
    // Useful for responsive design.
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    // Returns a fraction of the screen width based on the dividedBy and offsetBy parameters.
    // Useful for responsive design.
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    // Returns half of the screen width.
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    // Returns a third of the screen width.
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    // Returns a quarter of the screen width.
    screenWidthFraction(context, dividedBy: 4);
