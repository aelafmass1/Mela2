import 'package:intl/intl.dart';

String formatTime(DateTime date) {
  try {
    // Format the DateTime object into a string
    final DateFormat formatter =
        DateFormat.jm(); // 'jm' gives us the "hh:mm AM/PM" format

    return formatter.format(date);
  } catch (e) {
    return '';
  }
}
