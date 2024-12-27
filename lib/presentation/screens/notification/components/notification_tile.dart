// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/presentation/screens/%20money_transfer/components/search_receiver_page.dart';

import '../../../../data/models/notification_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../widgets/text_widget.dart';
import 'notification_card.dart';

/// NotificationTile widget
/// This widget is used to render notification tiles
/// It takes a NotificationModel as a parameter
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // switch on the type of the notification
    // switch on the type of the notification
    switch (notification.type) {
      // Render a failed transfer card
      case 'FAILED_TRANSFER':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Transfer Failed',
          buttonTitle: 'Retry',
          cardIcon: Assets.images.svgs.addMoneyFailIcon,
        );

      // Render a security issue card
      case 'SECURITY_ISSUE':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Security Issue',
          buttonTitle: 'Resolve',
          cardIcon: Assets.images.svgs.warningIcon,
        );

      // Render a sent money card
      case 'SENT_MONEY':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Money Sent',
          buttonTitle: 'View Details',
          cardIcon: Assets.images.svgs.addMoney,
        );

      // Render an Equb saving notification card
      case 'EQUB':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Equb Saving',
          buttonTitle: 'Pay Now',
          cardIcon: Assets.images.svgs.equbSavingIcon,
        );

      // Render a request money card
      case 'REQUEST_MONEY':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Money Requested',
          buttonTitle: 'Confirm',
          cardIcon: Assets.images.svgs.requestMoneyIcon,
          onCardTap: () => context.goNamed(RouteName.moneyRequestDetail,
              extra: notification.referenceId),
        );

      // Render a received money card
      case 'RECEIVED_MONEY':
        return NotificationCard(
          notification: notification,
          cardTitle: 'Money Received',
          buttonTitle: 'View Details',
          cardIcon: Assets.images.svgs.addMoney,
        );

      // If the type is not recognized, render a text widget
      default:
        return const TextWidget(text: 'No Notification Found');
    }
  }
}
