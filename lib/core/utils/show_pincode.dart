import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/screens/pincode_screen/pincode_screen.dart';

/// Shows a modal bottom sheet with a [PincodeScreen] to capture a user's PIN code.
///
/// This function is used to display a modal bottom sheet that covers the entire screen
/// and contains a [PincodeScreen] widget. The user can enter their PIN code in this
/// screen, and the function will return `true` if the PIN code is valid, or `false`
/// otherwise.
///
/// The [showPincode] function is typically used in scenarios where the user needs to
/// verify their identity, such as before performing a sensitive transaction or
/// accessing sensitive data.
///
/// Returns:
///   A [Future<bool>] that resolves to `true` if the user enters a valid PIN code,
///   or `false` otherwise.
Future<bool> showPincode(BuildContext context) async {
  bool result = false;
  await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 100.sh,
        child: PincodeScreen(
          result: (isValid) {
            result = isValid;
          },
        ),
      );
    },
  );
  return result;
}
