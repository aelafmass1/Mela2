import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/consent_screen.dart';

Future showConsent(BuildContext context) async {
  bool result = false;
  await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 100.sh,
        child: ConsentScreen(
          result: (isValid) {
            result = isValid;
          },
        ),
      );
    },
  );
  return result;
}
