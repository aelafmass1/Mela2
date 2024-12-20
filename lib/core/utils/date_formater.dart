import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  try {
    // Format to 'MMM d, yyyy'
    String formattedDate = DateFormat('MMM d, yyyy').format(date);
    return formattedDate;
  } catch (e) {
    return '';
  }
}
