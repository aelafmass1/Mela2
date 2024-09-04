import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

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
  final birthDateController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();
  final phoneNumberController = TextEditingController();

  bool termAndConditionAgreed = false;
  bool enableFaceId = true;

  String selectedCoutry = 'usa';

  final _formKey = GlobalKey<FormState>();

  String selectedGender = '';

  DateTime? birthdayDate;

  String? strongPasswordValidator(password) {
    if (password!.isEmpty) {
      return 'password is empty';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (password1Controller.text != password2Controller.text) {
      return 'Password are not indentical';
    }
    return null;
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
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'First Name is Empty';
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
                        validator: (text) {
                          if (text!.isEmpty) {
                            return 'Last Name is Empty';
                          }
                          return null;
                        },
                        controller: lastNameController,
                        hintText: 'Enter your last name',
                      ),
                      const SizedBox(height: 15),
                      // const TextWidget(
                      //   text: 'Gender *',
                      //   fontSize: 12,
                      //   weight: FontWeight.w400,
                      // ),
                      // const SizedBox(height: 5),
                      // DropdownButtonFormField(
                      //   validator: (value) {
                      //     if (selectedGender.isEmpty) {
                      //       return 'Gender not selected';
                      //     }
                      //     return null;
                      //   },
                      //   hint: const TextWidget(
                      //     text: 'Select Gender',
                      //     fontSize: 14,
                      //     color: Color(0xFF8E8E8E),
                      //     weight: FontWeight.w500,
                      //   ),
                      //   icon: const Icon(Icons.keyboard_arrow_down),
                      //   decoration: InputDecoration(
                      //     contentPadding: const EdgeInsets.symmetric(
                      //         horizontal: 20, vertical: 18),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(40),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(40),
                      //       borderSide: const BorderSide(
                      //         color: ColorName.primaryColor,
                      //         width: 2,
                      //       ),
                      //     ),
                      //   ),
                      //   items: const [
                      //     DropdownMenuItem(
                      //       value: 'male',
                      //       child: TextWidget(
                      //         text: 'Male',
                      //         type: TextType.small,
                      //       ),
                      //     ),
                      //     DropdownMenuItem(
                      //       value: 'female',
                      //       child: TextWidget(
                      //         text: 'Female',
                      //         type: TextType.small,
                      //       ),
                      //     )
                      //   ],
                      //   onChanged: (value) {
                      //     if (value != null) {
                      //       setState(() {
                      //         selectedGender = value;
                      //       });
                      //     }
                      //   },
                      // ),
                      // const SizedBox(height: 15),
                      // const TextWidget(
                      //   text: 'Birthdate *',
                      //   fontSize: 12,
                      //   weight: FontWeight.w400,
                      // ),
                      // const SizedBox(height: 5),
                      // TextFieldWidget(
                      //   validator: (text) {
                      //     if (text!.isEmpty) {
                      //       return 'birthdate is empty';
                      //     }
                      //   },
                      //   readOnly: true,
                      //   onTab: () async {
                      //     birthdayDate = await showDatePicker(
                      //       context: context,
                      //       firstDate: DateTime(1900),
                      //       lastDate: DateTime.now(),
                      //     );
                      //     if (birthdayDate != null) {
                      //       birthDateController.text =
                      //           DateFormat('MMMM dd, yyyy')
                      //               .format(birthdayDate!);
                      //     }
                      //   },
                      //   suffix: const Padding(
                      //     padding: EdgeInsets.only(right: 20),
                      //     child: Icon(
                      //       Icons.calendar_month_outlined,
                      //       size: 25,
                      //       color: ColorName.grey,
                      //     ),
                      //   ),
                      //   controller: birthDateController,
                      //   hintText: 'Select your birthdate',
                      // ),
                      // const SizedBox(height: 15),
                      const TextWidget(
                        text: 'Email *',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
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
                      SizedBox(height: 20),
                      const TextWidget(
                        text: 'Password',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        validator: strongPasswordValidator,
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
                        validator: strongPasswordValidator,
                        controller: password2Controller,
                        hintText: 'Confirm your password',
                      ),
                      const SizedBox(height: 25),
                      const TextWidget(
                        text: 'Phone Number',
                        fontSize: 12,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 5),
                      TextFieldWidget(
                        prefixText:
                            selectedCoutry == 'ethiopia' ? '+251' : '+1',
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
                                        backgroundImage: Assets
                                            .images.ethiopianFlag
                                            .provider(),
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
                              shape: CircleBorder(),
                              value: termAndConditionAgreed,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    termAndConditionAgreed = value;
                                  });
                                }
                              }),
                          RichText(
                              text: TextSpan(
                                  text: 'I have read & agree to the ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 12,
                                      ),
                                  children: const [
                                TextSpan(
                                    text: 'Term & Conditions',
                                    style: TextStyle(
                                      color: ColorName.primaryColor,
                                    ))
                              ])),
                          const SizedBox(height: 20),
                        ],
                      )
                      //
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFail) {
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: state.reason,
                      );
                    } else if (state is AuthSuccess) {
                      String phoneCode =
                          selectedCoutry == 'ethiopia' ? '+251' : '+1';
                      String phoneNumber =
                          phoneCode + phoneNumberController.text;
                      context.read<AuthBloc>().add(
                            SendOTP(
                              phoneNumber: phoneNumber,
                            ),
                          );
                      //
                    } else if (state is SendOTPFail) {
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: state.reason,
                      );
                    } else if (state is SendOTPSuccess) {
                      String phoneCode =
                          selectedCoutry == 'ethiopia' ? '+251' : '+1';
                      String phoneNumber =
                          phoneCode + phoneNumberController.text;
                      UserModel user = widget.userModel.copyWith(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: emailController.text,
                        password: password1Controller.text,
                        phoneNumber: phoneNumber,
                      );
                      context.pushNamed(
                        RouteName.otp,
                        extra: user,
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWidget(
                        color: termAndConditionAgreed
                            ? ColorName.primaryColor
                            : Colors.grey.withOpacity(0.5),
                        child: state is AuthLoading || state is SendOTPLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Next',
                                type: TextType.small,
                                color: Colors.white,
                              ),
                        onPressed: () {
                          if (termAndConditionAgreed) {
                            if (_formKey.currentState!.validate()) {
                              String phoneCode =
                                  selectedCoutry == 'ethiopia' ? '+251' : '+1';
                              String phoneNumber =
                                  phoneCode + phoneNumberController.text;
                              UserModel user = widget.userModel.copyWith(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                password: password1Controller.text,
                                phoneNumber: phoneNumber,
                              );
                              context
                                  .read<AuthBloc>()
                                  .add(CreateAccount(userModel: user));
                            }
                          }
                        });
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
