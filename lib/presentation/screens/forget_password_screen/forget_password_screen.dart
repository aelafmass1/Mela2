// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_login_page.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/location/location_bloc.dart';
import '../../../config/routing.dart';
import '../../../data/models/user_model.dart';
import '../../../gen/assets.gen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final String routeName;
  const ForgetPasswordScreen({super.key, required this.routeName});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  PhoneNumber initialNumber = PhoneNumber(isoCode: 'US');
  PhoneNumber selectedNumber = PhoneNumber(isoCode: 'US');

  final phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _phoneNumberNode = FocusNode();
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
    _phoneNumberNode.dispose();
    phoneNumberController.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text:
                    'Forget my ${widget.routeName == RouteName.newPincode ? 'PIN' : 'Password'}',
                fontSize: 20,
                color: ColorName.primaryColor,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 7),
              const TextWidget(
                text: 'Please enter your phone number to reset.',
                color: ColorName.grey,
                fontSize: 14,
              ),
              const SizedBox(height: 40),
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
                  focusNode: _phoneNumberNode,
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      selectedNumber = number;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone Number is empty';
                    }
                    if (!isPhoneNumberValid) {
                      return 'Please enter a valid phone number';
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
                  selectorButtonOnErrorPadding: 0,
                  selectorTextStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  onInputValidated: (bool value) {
                    setState(() {
                      isPhoneNumberValid = value;
                    });
                  },
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  initialValue: initialNumber,
                  spaceBetweenSelectorAndTextField: 0,
                  textFieldController: phoneNumberController,
                  formatInput: false,
                  cursorColor: ColorName.primaryColor,
                  keyboardType: TextInputType.phone,
                  inputDecoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E8E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
                      final countryCode = selectedNumber.dialCode!.substring(1);
                      context.pushNamed(
                        RouteName.otp,
                        extra: UserModel(
                          countryCode: int.tryParse(countryCode) ?? 0,
                          phoneNumber: phoneN,
                          toScreen: widget.routeName,
                        ),
                      );
                    } catch (error) {
                      log(error.toString());
                    }
                  }
                },
                builder: (context, state) {
                  return ButtonWidget(
                      child: state is SendOTPLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Next',
                              type: TextType.small,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final phoneN = selectedNumber.phoneNumber!.replaceAll(
                            selectedNumber.dialCode!,
                            '',
                          );
                          final countryCode =
                              selectedNumber.dialCode!.substring(1);
                          final signature = await SmsAutoFill().getAppSignature;
                          if (widget.routeName == RouteName.newPassword) {
                            context.read<AuthBloc>().add(
                                  SendOTPForPasswordReset(
                                    phoneNumber: int.tryParse(phoneN) ?? 0,
                                    countryCode: int.tryParse(countryCode) ?? 0,
                                    signature: signature,
                                  ),
                                );
                          } else if (widget.routeName == RouteName.newPincode) {
                            final isLoggedIn = await showLoginPage(
                              context,
                              phoneNumber: phoneNumberController.text,
                              isoCode: selectedNumber.isoCode ?? '',
                              dialCode: selectedNumber.dialCode ?? '',
                            );

                            if (isLoggedIn) {
                              final token = await getToken();
                              if (token != null) {
                                context.read<AuthBloc>().add(
                                      SendOTPForPincodeReset(
                                        accessToken: token,
                                        phoneNumber: int.tryParse(phoneN) ?? 0,
                                        countryCode:
                                            int.tryParse(countryCode) ?? 0,
                                        signature: signature,
                                      ),
                                    );
                              }
                            }
                          }
                        }
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
