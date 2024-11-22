import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/presentation/screens/pincode_screen/pincode_login_screen.dart';
import 'package:transaction_mobile_app/presentation/widgets/transfer_modal_sheet.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LifecycleManager extends WidgetsBindingObserver {
  static final LifecycleManager _instance = LifecycleManager._internal();

  factory LifecycleManager() {
    return _instance;
  }

  LifecycleManager._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this); // Start observing lifecycle
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Logout logic when app goes to background or is closed
      await _logoutUser();
    }
  }

  Future<void> _logoutUser() async {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PincodeLoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop observing lifecycle
  }
}
