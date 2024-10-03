import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/pin_entry_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/keypad_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

class SetPincodeScreen extends StatefulWidget {
  final UserModel user;
  const SetPincodeScreen({super.key, required this.user});

  @override
  State<SetPincodeScreen> createState() => _SetPincodeScreenState();
}

class _SetPincodeScreenState extends State<SetPincodeScreen> {
  bool showResendButton = false;
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();
  bool isValid = false;

  final pinEntryWidgetKey = GlobalKey<PinEntryWidgetState>();

  String firstPincode = '';
  validate() {
    final pins = getAllPins();
    final valid = pins.length == 6;

    setState(() {
      isValid = valid;
    });
  }

  List<String> getAllPins() {
    final pin = pinEntryWidgetKey.currentState?.getAllPins();
    return pin ?? <String>[];
  }

  clearPins() {
    pinEntryWidgetKey.currentState?.clearAll();
  }

  void insertPin(String pin) {
    pinEntryWidgetKey.currentState?.addPin(pin);
  }

  void removeLast() {
    pinEntryWidgetKey.currentState?.clearLast();
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
            Padding(
                padding: const EdgeInsets.only(top: 40),
                child: PinEntryWidget(
                  key: pinEntryWidgetKey,
                )),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            ButtonWidget(
                color:
                    isValid ? ColorName.primaryColor : ColorName.grey.shade200,
                child: const TextWidget(
                  text: 'Continue',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isValid) {
                    final pins = getAllPins();
                    context.pushNamed(RouteName.confirmPinCode, extra: [
                      widget.user,
                      pins.join(),
                    ]);
                  }
                  //
                }),
            const Spacer(),
            SafeArea(
              child: KeypadWidget(onBackPressed: () {
                removeLast();
                validate();
              }, onKeyPressed: (val) {
                insertPin(val);
                validate();
              }),
            )
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
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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
