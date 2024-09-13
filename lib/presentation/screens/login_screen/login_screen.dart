import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';
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
  String selectedCoutry = 'usa';
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                // ResponsiveBuilder(builder: (context, sizingInfo) {
                //   return Padding(
                //     padding: const EdgeInsets.only(top: 99),
                //     child: SizedBox(
                //       width: ResponsiveUtil.forScreen(
                //           sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
                //       child: const TextWidget(
                //         text: 'Log in',
                //         type: TextType.large,
                //       ),
                //     ),
                //   );
                // }),
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
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: TextFieldWidget(
                    validator: (text) {
                      if (text!.isEmpty) {
                        return 'password is empty';
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
                // PhoneNumberBox(
                //   onChange: (value) {
                //     setState(() {
                //       countryCode = value;
                //     });
                //   },
                //   controller: phoneNumberController,
                // ),
                // PasswordBox(
                //   controller: passwordController,
                // ),
                const SizedBox(height: 30),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is LoginUserFail) {
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: state.reason,
                      );
                    } else if (state is LoginUserSuccess) {
                      setFirstTime(false);
                      setIsLoggedIn(true);
                      context.goNamed(RouteName.home); //
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
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  LoginUser(
                                    countryCode:
                                        selectedCoutry == 'ethiopia' ? 251 : 1,
                                    phoneNumber: phoneNumberController.text,
                                    password: passwordController.text,
                                  ),
                                );
                          }
                        });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
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
                          context.pushNamed(RouteName.createAccount,
                              extra: UserModel());
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
    );
  }
}
