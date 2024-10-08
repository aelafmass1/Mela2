import 'package:connectivity_plus/connectivity_plus.dart';

final Connectivity _connectivity = Connectivity();

/// Checks the device's network connectivity.
///
/// This function attempts to check the device's network connectivity by using the
/// `connectivity_plus` package. It returns `true` if the device is connected to
/// the internet, and `false` otherwise (including if an error occurs during the
/// connectivity check).
Future<bool> checkConnectivity() async {
  try {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  } catch (e) {
    return false; // Assume no connectivity on error
  }
}
