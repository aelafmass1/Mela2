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

  final _formKey = GlobalKey<FormState>();

  String selectedGender = '';

  DateTime? birthdayDate;

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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFail) {
                      showSnackbar(context,
                          title: 'Error', description: state.reason);
                    } else if (state is AuthSucces) {
                      showSnackbar(
                        context,
                        title: 'Success',
                        description: 'Account Created',
                      );
                      setFirstTime(false);
                      context.goNamed(RouteName.home);
                    }
                  },
                  builder: (context, state) {
                    return ButtonWidget(
                        child: state is AuthLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Next',
                                type: TextType.small,
                                color: Colors.white,
                              ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            UserModel user = widget.userModel.copyWith(
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              email: emailController.text,
                            );
                            context.pushNamed(
                              RouteName.profileUpload,
                              extra: user,
                            );
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
