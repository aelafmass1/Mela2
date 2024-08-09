import 'dart:developer';

import 'package:responsive_builder/responsive_builder.dart';

class ResponsiveUtil {
  static double forScreen({
    required SizingInformation sizingInfo,
    double? small,
    required double mobile,
    required double tablet,
    double? desktop,
    double? large,
  }) {
    if (sizingInfo.localWidgetSize.width > 1500) {
      // > 950px
      log('large');

      return large ?? tablet;
    } else if (sizingInfo.deviceScreenType == DeviceScreenType.desktop) {
      // > 950px
      log('desktop');

      return desktop ?? tablet;
    } else if (sizingInfo.deviceScreenType == DeviceScreenType.tablet) {
      // < 950px
      log('tablet');

      return tablet;
    } else if (sizingInfo.screenSize.width <= 412 &&
        sizingInfo.screenSize.height <= 732) {
      // < 300px
      log('small');

      return small ?? mobile;
    } else if (sizingInfo.deviceScreenType == DeviceScreenType.mobile) {
      // < 600px
      log('mobile');

      return mobile;
    } else {
      return mobile;
    }
  }
}
