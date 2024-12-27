// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/notification_model.dart';

import '../../../../core/utils/date_formater.dart';
import '../../../../core/utils/time_formater.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/custom_list_tile.dart';
import '../../../widgets/image_builder.dart';
import '../../../widgets/text_widget.dart';
import 'build_title_button.dart';
import 'parse_title.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final cardTitle;
  final buttonTitle;
  final cardIcon;
  final VoidCallback? onCardTap;

  const NotificationCard({
    required this.notification,
    required this.cardTitle,
    required this.buttonTitle,
    required this.cardIcon,
    this.onCardTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: ImageBuilder(
        image: cardIcon,
        height: mediumSize,
        circle: true,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: cardTitle,
                fontSize: middleSize,
              ),
              Visibility(
                visible: notification.read == false,
                child: Container(
                    width: smallSize,
                    height: smallSize,
                    decoration: const BoxDecoration(
                        color: ColorName.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: formatDate(notification.createdAt),
                color: ColorName.grey,
                fontSize: smallSize,
              ),
              TextWidget(
                text: formatTime(notification.createdAt),
                color: ColorName.grey,
                fontSize: smallSize,
              ),
            ],
          ),
          verticalSpaceSmall,
          ParseTitle(
            notification: notification,
            color: ColorName.primaryColor,
          ),
          verticalSpaceMiddle,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BuildTitleButton(
                color: ColorName.yellow,
                text: buttonTitle,
                onPressed: onCardTap ?? () {},
              )
            ],
          )
        ],
      ),
    );
  }
}
