import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/bloc/location_bloc.dart';
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
  bool showPassword = false;

  bool hasAccount = false;

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
    super.initState();
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
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        selectedNumber = number;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone Number is empty';
                      }
                      return null;
                    },
                    selectorConfig: const SelectorConfig(
                      useEmoji: true,
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      leadingPadding: 10,
                      useBottomSheetSafeArea: true,
                      setSelectorButtonAsPrefixIcon: false,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: initialNumber,
                    spaceBetweenSelectorAndTextField: 0,
                    textFieldController: phoneNumberController,
                    formatInput: true,
                    cursorColor: ColorName.primaryColor,
                    keyboardType: TextInputType.phone,
                    inputDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      hintText: 'Phone Number',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E8E),
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: ColorName.primaryColor,
                          )),
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
                          } else if (text.length < 8) {
                            return 'Password must be at least 8 characters long.';
                          }
                          return null;
                        },
                        obscurePassword: showPassword,
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

                  // TextFieldWidget(
                  //   prefixText: selectedCoutry == 'ethiopia' ? '+251' : '+1',
                  //   enableFocusColor: false,
                  //   prefix: Container(
                  //     width: 80,
                  //     height: 60,
                  //     margin: const EdgeInsets.only(right: 10),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(40),
                  //         border: Border.all(color: Colors.black54)),
                  //     child: Center(
                  //       child: DropdownButton(
                  //           value: selectedCoutry,
                  //           padding: EdgeInsets.zero,
                  //           underline: const SizedBox.shrink(),
                  //           icon: const Padding(
                  //             padding: EdgeInsets.only(left: 5.0),
                  //             child: Icon(Icons.keyboard_arrow_down),
                  //           ),
                  //           items: [
                  //             DropdownMenuItem(
                  //                 alignment: Alignment.center,
                  //                 value: 'ethiopia',
                  //                 child: CircleAvatar(
                  //                   radius: 13,
                  //                   backgroundImage:
                  //                       Assets.images.ethiopianFlag.provider(),
                  //                 )),
                  //             DropdownMenuItem(
                  //                 alignment: Alignment.center,
                  //                 value: 'usa',
                  //                 child: CircleAvatar(
                  //                   radius: 13,
                  //                   backgroundImage:
                  //                       Assets.images.usaFlag.provider(),
                  //                 )),
                  //           ],
                  //           onChanged: (value) {
                  //             if (value != null) {
                  //               setState(() {
                  //                 selectedCoutry = value;
                  //               });
                  //             }
                  //           }),
                  //     ),
                  //   ),
                  //   keyboardType: TextInputType.phone,
                  //   validator: (text) {
                  //     if (text!.isEmpty) {
                  //       return 'Phone Number is empty';
                  //     }
                  //     return null;
                  //   },
                  //   controller: phoneNumberController,
                  //   hintText: 'Phone Number',
                  // ),
                  const SizedBox(height: 40),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is SendOTPFail) {
                        showSnackbar(
                          context,
                          title: 'Error',
                          description: state.reason,
                        );
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
                        onPressed: () {
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
                                context.read<AuthBloc>().add(
                                      SendOTP(
                                        phoneNumber: int.tryParse(phoneN) ?? 0,
                                        countryCode:
                                            int.tryParse(countryCode) ?? 0,
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
                  const SizedBox(height: 40),
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
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const TextWidget(
                      text: '2024 | All right reserved © Mela Financial inc.',
                      color: Color(0xFF8D8D8D),
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
