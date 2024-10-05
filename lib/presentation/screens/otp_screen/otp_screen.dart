// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../gen/colors.gen.dart';

class OTPScreen extends StatefulWidget {
  final UserModel userModel;
  const OTPScreen({super.key, required this.userModel});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with CodeAutoFill {
  bool showResendButton = false;
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();
  bool isValid = false;
  int minute = 0;
  int second = 60;
  Timer? timer;

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

  clearPins() {
    pin1Controller.clear();
    pin2Controller.clear();
    pin3Controller.clear();
    pin4Controller.clear();
    pin5Controller.clear();
    pin6Controller.clear();
  }

  void startTimer() {
    if (mounted) {
      setState(() {
        showResendButton = false;
        minute = 1;
        second = 60;
      });
      if (timer?.isActive ?? false) {
        timer?.cancel();
      }
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

  /// Updates the OTP pin fields with the provided code.
  ///
  /// This method is used to automatically populate the OTP pin fields when the
  /// user receives the OTP code. It splits the code string into individual
  /// characters and sets the text of each pin field controller accordingly.
  ///
  /// If the [code] parameter is null, this method does nothing.
  void codeUpdated() {
    if (code != null) {
      final pins = code!.trim().split('');
      if (code!.trim().length == 6) {
        pin1Controller.text = pins[0];
        pin2Controller.text = pins[1];
        pin3Controller.text = pins[2];
        pin4Controller.text = pins[3];
        pin5Controller.text = pins[4];
        pin6Controller.text = pins[5];
      }
    }
  }

  @override
  void initState() {
    startTimer();
    super.initState();
    SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    super.dispose();
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    SmsAutoFill().unregisterListener();
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
                        onPressed: () async {
                          clearPins();
                          final signature = await SmsAutoFill().getAppSignature;
                          if (widget.userModel.toScreen == null) {
                            context.read<AuthBloc>().add(
                                  SendOTP(
                                    phoneNumber: int.tryParse(
                                            widget.userModel.phoneNumber!) ??
                                        0,
                                    countryCode: widget.userModel.countryCode!,
                                    signature: signature,
                                  ),
                                );
                          } else {
                            if (widget.userModel.toScreen ==
                                RouteName.newPassword) {
                              context.read<AuthBloc>().add(
                                    SendOTPForPasswordReset(
                                      phoneNumber: int.tryParse(
                                              widget.userModel.phoneNumber!) ??
                                          0,
                                      countryCode:
                                          widget.userModel.countryCode!,
                                      signature: signature,
                                    ),
                                  );
                            } else if (widget.userModel.toScreen ==
                                RouteName.newPincode) {
                              context.read<AuthBloc>().add(
                                    SendOTPForPincodeReset(
                                      phoneNumber: int.tryParse(
                                              widget.userModel.phoneNumber!) ??
                                          0,
                                      countryCode:
                                          widget.userModel.countryCode!,
                                      signature: signature,
                                    ),
                                  );
                            }
                          }
                        },
                        child: const TextWidget(
                          text: 'Resend',
                          fontSize: 16,
                          weight: FontWeight.w500,
                          color: ColorName.yellow,
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
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is OTPVerificationSuccess) {
                  if (widget.userModel.toScreen == null) {
                    context.pushNamed(
                      RouteName.createAccount,
                      extra: widget.userModel.copyWith(
                        verificationUUID: state.userId,
                      ),
                    );
                  } else {
                    context.pushNamed(
                      widget.userModel.toScreen!,
                      extra: widget.userModel.copyWith(
                        otp: getAllPins().join(),
                      ),
                    );
                  }
                } else if (state is OTPVerificationFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                } else if (state is SendOTPFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                } else if (state is SendOTPSuccess) {
                  startTimer();
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    color: isValid
                        ? ColorName.primaryColor
                        : ColorName.grey.shade200,
                    child: state is OTPVerificationLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Verify',
                            type: TextType.small,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      final pins = getAllPins();
                      if (isValid) {
                        context.read<AuthBloc>().add(
                              VerfiyOTP(
                                phoneNumber: int.tryParse(
                                        widget.userModel.phoneNumber!) ??
                                    0,
                                conutryCode: widget.userModel.countryCode!,
                                code: pins.join(),
                              ),
                            );
                      }
                    });
              },
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
