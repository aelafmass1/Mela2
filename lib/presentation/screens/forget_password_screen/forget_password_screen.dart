import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/bloc/location_bloc.dart';
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
  void dispose() {
    phoneNumberController.dispose();
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final phoneN = selectedNumber.phoneNumber!.replaceAll(
                            selectedNumber.dialCode!,
                            '',
                          );
                          final countryCode =
                              selectedNumber.dialCode!.substring(1);
                          if (widget.routeName == RouteName.newPassword) {
                            context.read<AuthBloc>().add(
                                  SendOTPForPasswordReset(
                                    phoneNumber: int.tryParse(phoneN) ?? 0,
                                    countryCode: int.tryParse(countryCode) ?? 0,
                                  ),
                                );
                          } else if (widget.routeName == RouteName.newPincode) {
                            context.read<AuthBloc>().add(
                                  SendOTPForPincodeReset(
                                    phoneNumber: int.tryParse(phoneN) ?? 0,
                                    countryCode: int.tryParse(countryCode) ?? 0,
                                  ),
                                );
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
