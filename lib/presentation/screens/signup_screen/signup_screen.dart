import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../../core/utils/responsive_util.dart';
import '../../widgets/text_widget.dart';
import '../login_screen/components/phone_number_box.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButtonWidget(),
            ResponsiveBuilder(builder: (context, sizingInfo) {
              return SizedBox(
                width: ResponsiveUtil.forScreen(
                    sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
                child: const TextWidget(
                  text: 'Enter your number',
                  type: TextType.large,
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 30),
              child: TextWidget(
                text: 'You will receive a 4 digit code for phone Verification',
                fontSize: 15,
                weight: FontWeight.w300,
              ),
            ),
            PhoneNumberBox(
              controller: phoneNumberController,
            ),
            ButtonWidget(
              topPadding: 40,
              child: TextWidget(
                text: 'SEND CODE',
                fontSize: 18,
                color: Colors.white,
              ),
              onPressed: () {
                //
              },
            )
          ],
        ),
      ),
    );
  }
}
