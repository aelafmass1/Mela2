import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/main.dart';
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
  String selectedCoutry = 'usa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: const TextWidget(
                    text: 'Next',
                    color: Colors.white,
                    type: TextType.small,
                  ),
                  onPressed: () {
                    Jumio.init(
                        "eyJhbGciOiJIUzUxMiIsInppcCI6IkdaSVAifQ.H4sIAAAAAAAA_5XOMQ7CMAwF0LtkxpKdOk7MxsjKDRInYWkBiUogIe5O2huw_v_09T-uvU-rOzoSUYka0XNSd3DZ7FxHHqLPFksA7WkCRq1QcmrQEYkbE1lsG98xU4-k5IFMCnDzHcrECFWqEVoVLWngV2__cLu0PvTj_lyXfIP1vlzB8jz7rduHvHRGDAmIMQB7GSeFK0zGOan2ZiG57w9fvJLI7AAAAA.0NpDK192_6kMSYfxFuqHPFkhdsKQBqieRvSqt3XAGLWRe7Y8u0aJalMa8TLEY8eA0XEw4TqRapVLDraRHUz4kQ",
                        "US");
                    Jumio.start();
                    // if (_formKey.currentState!.validate()) {
                    //   String phoneCode =
                    //       selectedCoutry == 'ethiopia' ? '+251' : '+1';
                    //   String phoneNumber =
                    //       phoneCode + phoneNumberController.text;
                    //   context.pushNamed(
                    //     RouteName.createAccount,
                    //     extra: UserModel(
                    //       phoneNumber: phoneNumber,
                    //     ),
                    //   );
                    // }
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
    );
  }
}
