import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ContactPermissionScreen extends StatelessWidget {
  final void Function() checkContactPermission;
  const ContactPermissionScreen(
      {super.key, required this.checkContactPermission});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        checkContactPermission();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SizedBox(
                width: 70,
                height: 32,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              width: 1,
                              color: Colors.black87,
                            ))),
                    onPressed: () {
                      context.pop();
                    },
                    child: const TextWidget(
                      text: 'Skip',
                      weight: FontWeight.w500,
                      type: TextType.small,
                      color: Colors.black87,
                    )),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Assets.images.contactPageImage.image(
                width: 350,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: TextWidget(
                text: 'Enable Contact Permission',
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 80.sw,
              child: const TextWidget(
                text:
                    'This is going to be the settings path on the users device to enable the contact permission for our App.',
                type: TextType.small,
                textAlign: TextAlign.center,
                fontSize: 12,
                weight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 80.sw,
              child: const TextWidget(
                text:
                    'Go to Settings > Apps > Mela Fi > Contact > Select Full Access',
                type: TextType.small,
                textAlign: TextAlign.center,
                fontSize: 12,
                weight: FontWeight.w600,
              ),
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: ButtonWidget(
                  child: const TextWidget(
                    text: 'Enable Permission',
                    type: TextType.small,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await openAppSettings();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
