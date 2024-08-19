import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/login_screen/components/password_box.dart';
import 'package:transaction_mobile_app/presentation/screens/login_screen/components/phone_number_box.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  String countryCode = '+1';

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResponsiveBuilder(builder: (context, sizingInfo) {
              return Padding(
                padding: const EdgeInsets.only(top: 99),
                child: SizedBox(
                  width: ResponsiveUtil.forScreen(
                      sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
                  child: const TextWidget(
                    text: 'Log in',
                    type: TextType.large,
                  ),
                ),
              );
            }),
            const Expanded(child: SizedBox()),
            PhoneNumberBox(
              onChange: (value) {
                setState(() {
                  countryCode = value;
                });
              },
              controller: phoneNumberController,
            ),
            PasswordBox(
              controller: passwordController,
            ),
            const Expanded(child: SizedBox()),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                } else if (state is AuthSucces) {
                  context.goNamed(RouteName.home); //
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    child: state is AuthLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Log In',
                            color: Colors.white,
                          ),
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            LoginUser(
                                phoneNumber:
                                    '$countryCode${phoneNumberController.text}',
                                password: passwordController.text),
                          );
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
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
