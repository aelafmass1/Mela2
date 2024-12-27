import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_field_widget.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateAccountScreen({super.key, required this.userModel});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();
  // final phoneNumberController = TextEditingController();

  final firstNameKey = GlobalKey<FormFieldState>();
  final lastNameKey = GlobalKey<FormFieldState>();
  final emailKey = GlobalKey<FormFieldState>();
  final password1Key = GlobalKey<FormFieldState>();
  final password2Key = GlobalKey<FormFieldState>();
  // final phoneNumberKey = GlobalKey<FormFieldState>();

  bool termAndConditionAgreed = false;
  bool enableFaceId = true;

  String selectedCoutry = 'usa';

  final _formKey = GlobalKey<FormState>();

  String selectedGender = '';

  DateTime? birthdayDate;

  String emailError = '';
  String phoneNumberError = '';

  Timer? _debounceTimer;

  debounceValidation(GlobalKey<FormFieldState> formKey) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Trigger validation after 500ms of inactivity (debounce period)

      formKey.currentState?.validate();
    });
  }
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    //controller dispose
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    // phoneNumberController.dispose();

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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: TextWidget(
                          text: 'Create account to get started',
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TextWidget(
                        text: 'First Name *',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        onChanged: (p0) {
                          debounceValidation(firstNameKey);
                        },
                        globalKey: firstNameKey,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'First Name is Empty';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(text)) {
                            return 'First Name should only contain letters';
                          }
                          return null;
                        },
                        controller: firstNameController,
                        hintText: 'Enter your first name',
                      ),
                      const SizedBox(height: 15),
                      const TextWidget(
                        text: 'Last Name *',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        onChanged: (p0) {
                          debounceValidation(lastNameKey);
                        },
                        globalKey: lastNameKey,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'Last Name is Empty';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(text)) {
                            return 'Last Name should only contain letters';
                          }
                          return null;
                        },
                        controller: lastNameController,
                        hintText: 'Enter your last name',
                      ),
                      const SizedBox(height: 15),

                      const TextWidget(
                        text: 'Email *',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        onChanged: (p0) {
                          debounceValidation(emailKey);
                        },
                        globalKey: emailKey,
                        errorText: emailError.isEmpty ? null : emailError,
                        keyboardType: TextInputType.emailAddress,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'Email is empty';
                          } else if (RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(text) ==
                              false) {
                            return 'invalid email';
                          }
                          return null;
                        },
                        controller: emailController,
                        hintText: 'Enter your email address',
                      ),
                      // const SizedBox(height: 25),
                      // const TextWidget(
                      //   text: 'Phone Number',
                      //   fontSize: 12,
                      //   weight: FontWeight.w400,
                      // ),
                      // const SizedBox(height: 5),
                      // TextFieldWidget(
                      //   onChanged: (p0) {
                      //     debounceValidation(phoneNumberKey);
                      //   },
                      //   globalKey: phoneNumberKey,
                      //   errorText:
                      //       phoneNumberError.isEmpty ? null : phoneNumberError,
                      //   prefixText:
                      //       selectedCoutry == 'ethiopia' ? '+251' : '+1',
                      //   enableFocusColor: false,
                      //   prefix: Container(
                      //     width: 80,
                      //     height: 55,
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
                      //                   backgroundImage: Assets
                      //                       .images.ethiopianFlag
                      //                       .provider(),
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
                      //             debounceValidation(phoneNumberKey);
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
                      //     if (selectedCoutry == 'ethiopia') {
                      //       // RegEx for Ethiopian (+251) phone numbers (9 digits after country code)
                      //       final ethiopianPhoneRegex = RegExp(r'^\+251\d{9}$');
                      //       if (ethiopianPhoneRegex.hasMatch(
                      //               '+251${phoneNumberController.text}') ==
                      //           false) {
                      //         return 'Invalid Ethiopian Number';
                      //       }
                      //     } else {
                      //       // RegEx for US (+1) phone numbers (10 digits after country code)
                      //       final usPhoneRegex = RegExp(r'^\+1\d{10}$');
                      //       if (usPhoneRegex.hasMatch(
                      //               '+1${phoneNumberController.text}') ==
                      //           false) {
                      //         return 'Invalid US Number';
                      //       }
                      //     }

                      //     return null;
                      //   },
                      //   controller: phoneNumberController,
                      //   hintText: 'Phone Number',
                      // ),
                      const SizedBox(height: 20),
                      const TextWidget(
                        text: 'Password',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        onChanged: (p0) {
                          debounceValidation(password1Key);
                        },
                        globalKey: password1Key,
                        obscurePassword: !showPassword,
                        suffix: IconButton(
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
                        validator: (password) {
                          if (password!.isEmpty) {
                            return 'password is empty';
                          } else if (password.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }

                          return null;
                        },
                        controller: password1Controller,
                        hintText: 'Enter your password',
                      ),
                      const SizedBox(height: 25),
                      const TextWidget(
                        text: 'Confirm Password',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        onChanged: (p0) {
                          debounceValidation(password2Key);
                        },
                        globalKey: password2Key,
                        validator: (password) {
                          if (password!.isEmpty) {
                            return 'password is empty';
                          } else if (password.length < 8) {
                            return 'Password must be at least 8 characters long.';
                          }
                          if (password1Controller.text !=
                              password2Controller.text) {
                            return 'Password are not indentical';
                          }
                          return null;
                        },
                        controller: password2Controller,
                        obscurePassword: !showConfirmPassword,
                        hintText: 'Confirm your password',
                         suffix: IconButton(
                           icon: Icon(
                             showConfirmPassword
                                 ? Icons.remove_red_eye
                                 : Icons.remove_red_eye_outlined,
                             color: ColorName.grey,
                           ),
                           onPressed: () {
                             setState(() {
                               showConfirmPassword = !showConfirmPassword;
                             });
                           },
                         ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(Assets.images.svgs.faceId),
                              const SizedBox(width: 10),
                              const TextWidget(
                                text: 'Enable Face ID',
                                fontSize: 16,
                                weight: FontWeight.w400,
                              ),
                            ],
                          ),
                          Switch(
                              thumbColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              activeColor: ColorName.green,
                              value: enableFaceId,
                              onChanged: (value) {
                                setState(() {
                                  enableFaceId = value;
                                });
                              })
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                              activeColor: ColorName.primaryColor,
                              shape: const CircleBorder(),
                              value: termAndConditionAgreed,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    termAndConditionAgreed = value;
                                  });
                                }
                              }),
                          Row(
                            children: [
                              RichText(
                                  text: TextSpan(
                                text: 'I have read & agree to the',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontSize: 12,
                                    ),
                              )),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                ),
                                onPressed: () {
                                  //
                                },
                                child: const TextWidget(
                                  text: 'Term & Condition',
                                  fontSize: 12,
                                  color: ColorName.primaryColor,
                                  weight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                      //
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is CheckEmailExistsFail) {
                      setState(() {
                        emailError = state.reason;
                      });
                      showSnackbar(context, description: state.reason);
                    } else if (state is CheckEmailExistsSuccess) {
                      UserModel user = widget.userModel.copyWith(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: emailController.text,
                        password: password1Controller.text,
                      );
                      context.pushNamed(
                        RouteName.setPinCode,
                        extra: user,
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWidget(
                      color: termAndConditionAgreed
                          ? ColorName.primaryColor
                          : Colors.grey.withOpacity(0.5),
                      child: state is CheckEmailExistsLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Next',
                              type: TextType.small,
                              color: Colors.white,
                            ),
                      onPressed: () {
                        if (termAndConditionAgreed) {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(CheckEmailExists(
                                  email: emailController.text,
                                ));
                          }
                        }
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
