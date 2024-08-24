import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

import '../../widgets/text_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String selectedCoutry = 'usa';

  Future<void> sendOTP(String phoneNumber) async {
    setState(() {
      isLoading = true;
    });
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign the user in (optional)
        log('sign in completed');
        await _auth.signInWithCredential(credential);
        setState(() {
          isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          log('The provided phone number is not valid.');
          showSnackbar(
            context,
            title: 'Error',
            description: 'The provided phone number is not valid.',
          );
        } else {
          showSnackbar(
            context,
            title: 'Error',
            description: 'Failed to verify phone number',
          );
          log('Failed to verify phone number: ${e.message}');
        }
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verificationId to use later for signing in with the OTP
        // and show an input field for the user to enter the OTP
        showSnackbar(
          context,
          title: 'Success',
          description: 'OTP has been sent',
        );
        log('OTP has been sent. $verificationId');
        setState(() {
          isLoading = false;
        });

        context.pushNamed(
          RouteName.otp,
          extra: UserModel(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout (optional)
        setState(() {
          isLoading = false;
        });
      },
      timeout: const Duration(seconds: 60), // Optional timeout duration
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
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
              TextFieldWidget(
                prefixText: selectedCoutry == 'ethiopia' ? '+251' : '+1',
                enableFocusColor: false,
                prefix: Container(
                  width: 80,
                  height: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black54)),
                  child: Center(
                    child: DropdownButton(
                        value: selectedCoutry,
                        padding: EdgeInsets.zero,
                        underline: const SizedBox.shrink(),
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                        items: [
                          DropdownMenuItem(
                              alignment: Alignment.center,
                              value: 'ethiopia',
                              child: CircleAvatar(
                                radius: 13,
                                backgroundImage:
                                    Assets.images.ethiopianFlag.provider(),
                              )),
                          DropdownMenuItem(
                              alignment: Alignment.center,
                              value: 'usa',
                              child: CircleAvatar(
                                radius: 13,
                                backgroundImage:
                                    Assets.images.usaFlag.provider(),
                              )),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCoutry = value;
                            });
                          }
                        }),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (text) {
                  if (text!.isEmpty) {
                    return 'Phone Number is empty';
                  }
                  return null;
                },
                controller: phoneNumberController,
                hintText: 'Phone Number',
              ),
              const SizedBox(height: 30),
              ButtonWidget(
                child: isLoading
                    ? const LoadingWidget()
                    : const TextWidget(
                        text: 'Next',
                        color: Colors.white,
                        type: TextType.small,
                      ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String phoneCode =
                        selectedCoutry == 'ethiopia' ? '+251' : '+1';
                    String phoneNumber = phoneCode + phoneNumberController.text;

                    // sendOTP(phoneNumber);
                    context.pushNamed(
                      RouteName.otp,
                      extra: UserModel(
                        phoneNumber: phoneNumber,
                      ),
                    );
                  }
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
              const Expanded(child: SizedBox()),
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
    );
  }
}
