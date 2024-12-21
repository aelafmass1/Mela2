import 'package:transaction_mobile_app/data/models/notification_model.dart';

String getTokenValueNotification(String t, NotificationModel notification) {
  final token = t.replaceAll(RegExp('[{}\$.]'), '');
  final data = notification.data?.where((t) => token.contains(t.key)).toList();
  if (data?.isNotEmpty == true) {
    if (data != null) {
      if (token == 'amount') {
        return '\$${data.first.value}';
      }
      return data.first.value;
    }
  }

  return token;
}
