import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../../config/routing.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/keypad_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/pin_entry_widget.dart';
import '../../widgets/text_widget.dart';

class NewPincodeScreen extends StatefulWidget {
  final UserModel userModel;
  const NewPincodeScreen({super.key, required this.userModel});

  @override
  State<NewPincodeScreen> createState() => _NewPincodeScreenState();
}

class _NewPincodeScreenState extends State<NewPincodeScreen> {
  bool showResendButton = false;
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
  void initState() {
    log(widget.userModel.toString());
    super.initState();
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
              text: 'Enter New PIN',
              fontSize: 20,
              color: ColorName.primaryColor,
            ),
            const SizedBox(height: 7),
            const TextWidget(
              text: 'Please keep your PIN confidential & secure.',
              color: ColorName.grey,
              fontSize: 14,
            ),
            Padding(
                padding: const EdgeInsets.only(top: 40),
                child: PinEntryWidget(
                  key: pinEntryWidgetKey,
                )),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is ResetFail) {
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                } else if (state is ResetSuccess) {
                  context.goNamed(RouteName.login);
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    color: isValid
                        ? ColorName.primaryColor
                        : ColorName.grey.shade200,
                    child: state is ResetLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Set PIN',
                            type: TextType.small,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      if (isValid) {
                        final pins = getAllPins().join();
                        context.read<AuthBloc>().add(ResetPincode(
                              phoneNumber:
                                  int.tryParse(widget.userModel.phoneNumber!) ??
                                      0,
                              otp: widget.userModel.otp!,
                              countryCode: widget.userModel.countryCode!,
                              newPincode: pins,
                            ));
                      }
                      //
                    });
              },
            ),
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
}
