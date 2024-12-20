import 'package:flutter/material.dart';

import '../../../../core/utils/get_token_value_notification.dart';
import '../../../../data/models/notification_model.dart';

class ParseTitle extends StatelessWidget {
  const ParseTitle({
    super.key,
    required this.notification,
    required this.color,
  });

  final NotificationModel notification;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = notification.title.trim().split(' ');
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        children: [
          for (var token in tokens)
            if (token.contains('{') && token.contains('}'))
              TextSpan(
                text: "${getTokenValueNotification(token, notification)} ",
                style: TextStyle(
                  color: color,
                ),
              )
            else
              TextSpan(
                text: "$token ",
              )
        ],
      ),
    );
  }
}
