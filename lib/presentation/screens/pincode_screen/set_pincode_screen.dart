import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_keyboard.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';

class SetPincodeScreen extends StatefulWidget {
  final UserModel user;
  const SetPincodeScreen({super.key, required this.user});

  @override
  State<SetPincodeScreen> createState() => _SetPincodeScreenState();
}

class _SetPincodeScreenState extends State<SetPincodeScreen> {
  final pin6Controller = TextEditingController();
  bool isValid = false;

  String pins = '';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: 'Set a PIN',
                color: ColorName.primaryColor,
                fontSize: 20,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 5),
              const TextWidget(
                text: 'Please remember to keep it secure.',
                fontSize: 14,
                color: ColorName.grey,
                weight: FontWeight.w400,
              ),
              CustomKeyboard(
                onComplete: (p) {
                  log(p);
                  if (p.length == 6) {
                    setState(() {
                      pins = p;
                      isValid = true;
                    });
                  } else {
                    setState(() {
                      pins = p;
                      isValid = false;
                    });
                  }
                },
                buttonWidget: ButtonWidget(
                    color: isValid
                        ? ColorName.primaryColor
                        : ColorName.grey.shade200,
                    child: const TextWidget(
                      text: 'Continue',
                      type: TextType.small,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (isValid) {
                        context.pushNamed(RouteName.confirmPinCode, extra: [
                          widget.user,
                          pins.trim(),
                        ]);
                      }
                      //
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
