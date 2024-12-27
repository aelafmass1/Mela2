import 'dart:async';
import 'package:flutter/material.dart';

class LifecycleManager extends WidgetsBindingObserver {
  static final LifecycleManager _instance = LifecycleManager._internal();

  Timer? _timer;

  factory LifecycleManager() {
    return _instance;
  }

  LifecycleManager._internal();

  VoidCallback? onLogout; // Callback to trigger logout navigation

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override

  /// Handles changes in the app's lifecycle state.
  ///
  /// When the app is paused, a 30-second timer is started. If the app remains
  /// paused for the full 30 seconds, the `onLogout` callback is called to trigger
  /// a logout navigation.
  ///
  /// When the app is resumed, the 30-second timer is canceled.
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (onLogout == null) return;
      _timer = Timer(const Duration(minutes: 30), () {
        onLogout?.call(); // Trigger logout navigation
      });
    } else if (state == AppLifecycleState.resumed) {
      _timer?.cancel();
    }
  }

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
