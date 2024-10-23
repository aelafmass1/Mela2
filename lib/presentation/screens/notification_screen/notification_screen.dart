import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TextWidget(
          text: 'Notification',
          weight: FontWeight.w700,
          fontSize: 20,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
                onPressed: () {
                  // TODO: implement clear notification
                },
                child: const TextWidget(
                  text: 'Clear',
                  type: TextType.small,
                  color: ColorName.grey,
                )),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Assets.images.noNotification.image(
                width: 350,
              ),
            ),
            const TextWidget(
              text: 'oops, You don’t have any Notification.',
              type: TextType.small,
              weight: FontWeight.w600,
            )
          ],
        ),
      ),
    );
  }
}
