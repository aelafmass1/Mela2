import 'dart:async' show Timer;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

import '../../../config/routing.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/text_widget.dart';

class NewPasswordScreen extends StatefulWidget {
  final UserModel userModel;
  const NewPasswordScreen({super.key, required this.userModel});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();

  final password1Key = GlobalKey<FormFieldState>();
  final password2Key = GlobalKey<FormFieldState>();

  bool obscrurePassword1 = true;
  bool obscrurePassword2 = true;

  Timer? _debounceTimer;

  debounceValidation(GlobalKey<FormFieldState> formKey) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      // Trigger validation after 600ms of inactivity (debounce period)

      formKey.currentState?.validate();
    });
  }

  @override
  void initState() {
    log(widget.userModel.toString());
    super.initState();
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextWidget(
                        text: 'Enter New Password',
                        fontSize: 20,
                        color: ColorName.primaryColor,
                      ),
                      const SizedBox(height: 7),
                      const TextWidget(
                        text:
                            'Please keep your password confidential & secure.',
                        color: ColorName.grey,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 40),
                      const TextWidget(
                        text: 'New Password*',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget(
                        globalKey: password1Key,
                        onChanged: (p0) {
                          debounceValidation(password1Key);
                        },
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'password is empty';
                          } else if (text.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscrurePassword1 = !obscrurePassword1;
                                });
                              },
                              icon: Icon(
                                obscrurePassword1
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                                size: 23,
                                color: ColorName.grey,
                              )),
                        ),
                        obscurePassword: obscrurePassword1,
                        controller: password1Controller,
                        hintText: 'Enter your new password',
                      ),
                      const SizedBox(height: 15),
                      const TextWidget(
                        text: 'Confirm Password *',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget(
                        globalKey: password2Key,
                        onChanged: (p0) {
                          debounceValidation(password2Key);
                        },
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'password is empty';
                          } else if (text.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          } else if (password1Controller.text.trim() !=
                              password2Controller.text.trim()) {
                            return "The passwords you entered don't match";
                          }
                          return null;
                        },
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscrurePassword2 = !obscrurePassword2;
                                });
                              },
                              icon: Icon(
                                obscrurePassword2
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                                size: 23,
                                color: ColorName.grey,
                              )),
                        ),
                        obscurePassword: obscrurePassword2,
                        controller: password2Controller,
                        hintText: 'Confirm your password',
                      ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 5),
                            TextWidget(
                              text: 'Has at least 6 characters',
                              type: TextType.small,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 5),
                            TextWidget(
                              text: 'Has a lowercase letter',
                              type: TextType.small,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 5),
                            TextWidget(
                              text: 'Has an uppercase letter & symbol',
                              type: TextType.small,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 5),
                            TextWidget(
                              text: 'Has a number',
                              type: TextType.small,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is ResetFail) {
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                } else if (state is ResetSuccess) {
                  context.goNamed(RouteName.login);
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    child: state is ResetLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Next',
                            color: Colors.white,
                            type: TextType.small,
                          ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              ResetPassword(
                                phoneNumber: int.tryParse(
                                        widget.userModel.phoneNumber!) ??
                                    0,
                                otp: widget.userModel.otp!,
                                countryCode: widget.userModel.countryCode!,
                                newPassword: password1Controller.text.trim(),
                              ),
                            );
                      }
                      //
                    });
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
