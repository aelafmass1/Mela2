import 'package:flutter/material.dart';

import '../../../../core/utils/calculate_duration_time.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class BuildTimeWidget extends StatelessWidget {
  const BuildTimeWidget({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextWidget(
          text: calculateDurationTime(notification.createdAt),
          fontSize: 10,
          color: ColorName.grey,
        ),
        Visibility(
          visible: notification.read == false,
          child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: ColorName.red, shape: BoxShape.circle)),
        )
      ],
    );
  }
}
