// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/location/location_bloc.dart';
import '../../../core/utils/settings.dart';
import '../../widgets/text_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  // String selectedCoutry = 'usa';

  PhoneNumber initialNumber = PhoneNumber(isoCode: 'US');
  PhoneNumber selectedNumber = PhoneNumber(isoCode: 'US');

  final _phoneNumberNode = FocusNode();

  bool showPassword = false;
  bool hasAccount = false;
  bool isPhoneNumberFocused = false;
  bool isPhoneNumberValid = false;

  @override
  void initState() {
    final countryCode = context.read<LocationBloc>().state.countryCode;
    if (countryCode != null) {
      setState(() {
        initialNumber = PhoneNumber(
          isoCode: countryCode,
        );
        selectedNumber = initialNumber;
      });
    }
    _phoneNumberNode.addListener(() {
      if (_phoneNumberNode.hasFocus) {
        setState(() {
          isPhoneNumberFocused = true;
        });
      } else {
        setState(() {
          isPhoneNumberFocused = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    _phoneNumberNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state.countryCode != null) {
          setState(() {
            initialNumber = PhoneNumber(
              isoCode: state.countryCode,
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      Assets.images.svgs.horizontalMelaLogo,
                    ),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      const TextWidget(
                        text: 'Hello There',
                        fontSize: 24,
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(width: 10),
                      SvgPicture.asset(Assets.images.svgs.hiEmoji),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const TextWidget(
                    text: 'Mobile number',
                    fontSize: 12,
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        width: isPhoneNumberFocused ? 2 : 1,
                        color: isPhoneNumberFocused
                            ? ColorName.primaryColor
                            : ColorName.grey,
                      ),
                      // color: Colors.amber,
                    ),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        if (phoneNumberController.text.isEmpty) {
                          setState(() {
                            hasAccount = false;
                          });
                        }
                        setState(() {
                          selectedNumber = number;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Phone Number is empty';
                        }
                        if (!isPhoneNumberValid) {
                          if (kIsWeb) {
                            return null;
                          }
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      onInputValidated: (bool value) {
                        setState(() {
                          isPhoneNumberValid = value;
                        });
                      },
                      selectorConfig: const SelectorConfig(
                        useEmoji: true,
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        leadingPadding: 10,
                        useBottomSheetSafeArea: true,
                        setSelectorButtonAsPrefixIcon: false,
                      ),
                      focusNode: _phoneNumberNode,
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      initialValue: initialNumber,
                      spaceBetweenSelectorAndTextField: 0,
                      textFieldController: phoneNumberController,
                      formatInput: false,
                      cursorColor: ColorName.primaryColor,
                      keyboardType: TextInputType.phone,
                      inputDecoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 17),
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8E8E8E),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: hasAccount,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: TextFieldWidget(
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'password is empty';
                          } else if (text.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        obscurePassword: !showPassword,
                        controller: passwordController,
                        hintText: 'Password',
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.remove_red_eye
                                  : Icons.remove_red_eye_outlined,
                              color: ColorName.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: hasAccount,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.pushNamed(
                            RouteName.forgetPassword,
                            extra: RouteName.newPassword,
                          );
                        },
                        child: const TextWidget(
                          text: 'Forgot password?   ',
                          fontSize: 14,
                          weight: FontWeight.w500,
                          color: ColorName.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is SendOTPFail) {
                        if (state.reason ==
                            'User with this phone number already exists and is active') {
                          setState(() {
                            hasAccount = true;
                          });
                        } else if (state.reason == 'Failed to send SMS') {
                          final phoneN = selectedNumber.phoneNumber!
                              .replaceAll(selectedNumber.dialCode!, '');
                          final countryCode =
                              selectedNumber.dialCode!.substring(1);
                          context.pushNamed(
                            RouteName.createAccount,
                            extra: UserModel(
                              countryCode: int.tryParse(countryCode) ?? 0,
                              phoneNumber: phoneN,
                              verificationUUID: state.userId,
                            ),
                          );
                        } else {
                          showSnackbar(
                            context,
                            title: 'Error',
                            description: state.reason,
                          );
                        }
                      } else if (state is SendOTPSuccess) {
                        try {
                          final phoneN = selectedNumber.phoneNumber!
                              .replaceAll(selectedNumber.dialCode!, '');
                          final countryCode =
                              selectedNumber.dialCode!.substring(1);
                          context.pushNamed(
                            RouteName.otp,
                            extra: UserModel(
                              countryCode: int.tryParse(countryCode) ?? 0,
                              phoneNumber: phoneN,
                            ),
                          );
                        } catch (error) {
                          log(error.toString());
                        }
                      } else if (state is LoginUserFail) {
                        showSnackbar(
                          context,
                          title: 'Error',
                          description: state.reason,
                        );
                      } else if (state is LoginUserSuccess) {
                        final countryCode =
                            selectedNumber.dialCode?.substring(1);
                        if (countryCode != null) {
                          setCountryCode(int.parse(countryCode));
                        }

                        setFirstTime(false);

                        context.pushNamed(RouteName.loginPincode); //
                      }
                    },
                    builder: (context, state) {
                      return ButtonWidget(
                        child:
                            state is SendOTPLoading || state is LoginUserLoading
                                ? const LoadingWidget()
                                : const TextWidget(
                                    text: 'Next',
                                    color: Colors.white,
                                    type: TextType.small,
                                  ),
                        onPressed: () async {
                          try {
                            if (_formKey.currentState!.validate()) {
                              log(selectedNumber.toString());
                              final phoneN =
                                  selectedNumber.phoneNumber!.replaceAll(
                                selectedNumber.dialCode!,
                                '',
                              );
                              final countryCode =
                                  selectedNumber.dialCode!.substring(1);
                              log(phoneN);
                              log(countryCode);
                              if (hasAccount) {
                                context.read<AuthBloc>().add(
                                      LoginUser(
                                        phoneNumber: phoneN,
                                        password: passwordController.text,
                                        countryCode:
                                            int.tryParse(countryCode) ?? 0,
                                      ),
                                    );
                              } else {
                                final signature =
                                    await SmsAutoFill().getAppSignature;
                                context.read<AuthBloc>().add(
                                      SendOTP(
                                        phoneNumber: int.tryParse(phoneN) ?? 0,
                                        countryCode:
                                            int.tryParse(countryCode) ?? 0,
                                        signature: signature,
                                      ),
                                    );
                              }
                            }
                          } catch (error) {
                            log(error.toString());
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                        text: 'Already have an account?',
                        type: TextType.small,
                        weight: FontWeight.w400,
                      ),
                      TextButton(
                        onPressed: () {
                          context.goNamed(RouteName.login);
                        },
                        child: const TextWidget(
                          text: 'Log in',
                          type: TextType.small,
                          weight: FontWeight.w700,
                          color: ColorName.primaryColor,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: TextWidget(
                      text: '2024 | All right reserved © Mela Financial inc.',
                      color: Color(0xFF8D8D8D),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
