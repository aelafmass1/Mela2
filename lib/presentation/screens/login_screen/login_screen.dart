import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/location/location_bloc.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final phoneNumberKey = GlobalKey<FormFieldState>();
  final passwordKey = GlobalKey<FormFieldState>();

  PhoneNumber initialNumber = PhoneNumber(isoCode: 'US');
  PhoneNumber selectedNumber = PhoneNumber(isoCode: 'US');

  final _phoneNumberNode = FocusNode();

  bool isPhoneNumberFocused = false;
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

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
    phoneNumberController.dispose();
    passwordController.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  Timer? _debounceTimer;

  debounceValidation(GlobalKey<FormFieldState> formKey) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      // Trigger validation after 600ms of inactivity (debounce period)

      formKey.currentState?.validate();
    });
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 20),
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
                      focusNode: _phoneNumberNode,
                      fieldKey: phoneNumberKey,
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          selectedNumber = number;
                        });
                        debounceValidation(phoneNumberKey);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Phone Number is empty';
                        }
                        return null;
                      },
                      selectorButtonOnErrorPadding: 0,
                      selectorTextStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
                        // focusedBorder: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(40),
                        //     borderSide: const BorderSide(
                        //       color: ColorName.primaryColor,
                        //     )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: TextFieldWidget(
                      onChanged: (p0) {
                        debounceValidation(passwordKey);
                      },
                      globalKey: passwordKey,
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
                                ? Icons.remove_red_eye_outlined
                                : Icons.remove_red_eye,
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
                  const SizedBox(height: 10),
                  Align(
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
                  const SizedBox(height: 10),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is LoginUserFail) {
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

                        context.pushNamed(RouteName.loginPincode);
                      }
                    },
                    builder: (context, state) {
                      return ButtonWidget(
                          child: state is LoginUserLoading
                              ? const LoadingWidget()
                              : const TextWidget(
                                  text: 'Log In',
                                  color: Colors.white,
                                ),
                          onPressed: () {
                            try {
                              if (_formKey.currentState!.validate()) {
                                final phoneN =
                                    selectedNumber.phoneNumber!.replaceAll(
                                  selectedNumber.dialCode!,
                                  '',
                                );
                                final countryCode =
                                    selectedNumber.dialCode!.substring(1);
                                context.read<AuthBloc>().add(
                                      LoginUser(
                                        countryCode:
                                            int.tryParse(countryCode) ?? 0,
                                        phoneNumber: phoneN,
                                        password: passwordController.text,
                                      ),
                                    );
                              }
                            } catch (error) {
                              log(error.toString());
                            }
                          });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TextWidget(
                          text: 'Don’t have an account ?',
                          fontSize: 15,
                          weight: FontWeight.w300,
                        ),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(RouteName.signup);
                          },
                          child: const TextWidget(
                            text: 'Sign up',
                            fontSize: 18,
                            color: ColorName.primaryColor,
                            weight: FontWeight.w600,
                          ),
                        )
                      ],
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
