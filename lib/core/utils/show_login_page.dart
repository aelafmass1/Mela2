import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/screens/login_screen/components/login_bottom_sheet_page.dart';

Future<bool> showLoginPage(
  BuildContext context, {
  required String phoneNumber,
  required String isoCode,
  required String dialCode,
}) async {
  bool result = false;
  await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 100.sh,
        child: LoginBottomSheetPage(
          phoneNumber: phoneNumber,
          isoCode: isoCode,
          dialCode: dialCode,
          result: (isValid) {
            result = isValid;
          },
        ),
      );
    },
  );
  return result;
}
