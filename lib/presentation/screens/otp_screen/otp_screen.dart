import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../gen/colors.gen.dart';

class OTPScreen extends StatefulWidget {
  final UserModel userModel;
  const OTPScreen({super.key, required this.userModel});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool showResendButton = false;
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();
  bool isValid = false;
  int minute = 1;
  int second = 60;
  late Timer timer;

  List<String> getAllPins() {
    String pin1 = pin1Controller.text;
    String pin2 = pin2Controller.text;
    String pin3 = pin3Controller.text;
    String pin4 = pin4Controller.text;
    String pin5 = pin5Controller.text;
    String pin6 = pin6Controller.text;
    if (pin1.isNotEmpty &&
        pin2.isNotEmpty &&
        pin3.isNotEmpty &&
        pin4.isNotEmpty &&
        pin5.isNotEmpty &&
        pin6.isNotEmpty) {
      if (mounted) {
        setState(() {
          isValid = true;
        });
      }

      return [pin1, pin2, pin3, pin4, pin5, pin6];
    }
    if (mounted) {
      setState(() {
        isValid = false;
      });
    }

    return [];
  }

  void startTimer() {
    if (mounted) {
      setState(() {
        showResendButton = false;
      });
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (second == 0) {
        setState(() {
          minute--;
          second = 59;
        });
      } else {
        setState(() {
          second--;
        });
      }

      if (second == 0 && minute == 0) {
        if (mounted) {
          setState(() {
            showResendButton = true;
          });
        }

        t.cancel();
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SvgPicture.asset(
              Assets.images.svgs.horizontalMelaLogo,
              width: 130,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'OTP Verification',
              color: ColorName.primaryColor,
              fontSize: 20,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 5),
            const TextWidget(
              text: 'Enter the verification code we just sent you via SMS.',
              fontSize: 14,
              color: ColorName.grey,
              weight: FontWeight.w400,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPinBox(controller: pin1Controller),
                  _buildPinBox(controller: pin2Controller),
                  _buildPinBox(controller: pin3Controller),
                  _buildPinBox(controller: pin4Controller),
                  _buildPinBox(controller: pin5Controller),
                  _buildPinBox(controller: pin6Controller),
                ],
              ),
            ),
            const SizedBox(height: 20),
            showResendButton
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                        text: 'Didn’t receive code?',
                        fontSize: 16,
                        weight: FontWeight.w400,
                      ),
                      TextButton(
                        onPressed: () {
                          //
                        },
                        child: const TextWidget(
                          text: 'Resend',
                          fontSize: 16,
                          weight: FontWeight.w500,
                        ),
                      )
                    ],
                  )
                : Align(
                    alignment: Alignment.center,
                    child: TextWidget(
                      text:
                          '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
                      fontSize: 16,
                      weight: FontWeight.w400,
                      color: ColorName.grey,
                    ),
                  ),
            const SizedBox(height: 30),
            ButtonWidget(
                child: const TextWidget(
                  text: 'Verify',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.pushNamed(
                    RouteName.createPassword,
                    extra: widget.userModel,
                  );
                })
          ],
        ),
      ),
    );
  }

  Widget _buildPinBox({required TextEditingController controller}) {
    return SizedBox(
      height: 70,
      width: 13.sw,
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          getAllPins();
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: ColorName.primaryColor,
              // color: isValid ? Colors.white : Colors.black,
            ),
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
                width: 2,
              )),
        ),
      ),
    );
  }
}
