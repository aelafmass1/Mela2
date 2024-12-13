// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

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

import '../../../core/utils/settings.dart';
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

  bool isValid = false;
  int minute = 0;
  int second = 60;
  Timer? timer;

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
      if (code!.trim().length == 6) {
        pin1Controller.text = code?.trim() ?? '';
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
                          pin1Controller.clear();
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
                              final token = await getToken();
                              if (token != null) {
                                context.read<AuthBloc>().add(
                                      SendOTPForPincodeReset(
                                        accessToken: token,
                                        phoneNumber: int.tryParse(widget
                                                .userModel.phoneNumber!) ??
                                            0,
                                        countryCode:
                                            widget.userModel.countryCode!,
                                        signature: signature,
                                      ),
                                    );
                              }
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
                        otp: pin1Controller.text.trim(),
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
                      if (isValid) {
                        context.read<AuthBloc>().add(
                              VerfiyOTP(
                                phoneNumber: int.tryParse(
                                        widget.userModel.phoneNumber!) ??
                                    0,
                                conutryCode: widget.userModel.countryCode!,
                                code: pin1Controller.text.trim(),
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
      width: 90.sw,
      child: TextFormField(
        autofocus: true,
        controller: controller,
        onChanged: (value) {
          if (value.length == 6) {
            setState(() {
              isValid = true;
            });
            context.read<AuthBloc>().add(
                  VerfiyOTP(
                    phoneNumber:
                        int.tryParse(widget.userModel.phoneNumber!) ?? 0,
                    conutryCode: widget.userModel.countryCode!,
                    code: pin1Controller.text.trim(),
                  ),
                );
          } else {
            setState(() {
              isValid = false;
            });
          }
        },
        onTapOutside: (event) {
          if (Platform.isIOS) {
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
          LengthLimitingTextInputFormatter(6),
        ],
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          hintText: 'verificaton code',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF8E8E8E),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
                width: 2,
              )),
        ),
      ),
    );
  }
}
