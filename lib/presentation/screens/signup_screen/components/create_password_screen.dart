import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../gen/assets.gen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final UserModel userModel;
  const CreatePasswordScreen({super.key, required this.userModel});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();
  bool enableFaceId = true;
  final _formKey = GlobalKey<FormState>();

  String? strongPasswordValidator(password) {
    if (password!.isEmpty) {
      return 'password is empty';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r"""[!@#\$%\^&\*\(\)_\+\-=\{\}\[\]:;"\',<>\?\/\\\|~`]""")
        .hasMatch(password)) {
      return 'Password must contain at least one symbol (e.g., @, #, \$, %, etc.).';
    }
    if (password1Controller.text != password2Controller.text) {
      return 'Password are not indentical';
    }
    return null;
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
                      const TextWidget(
                        text: 'Create Password',
                        color: ColorName.primaryColor,
                        fontSize: 20,
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(height: 5),
                      const TextWidget(
                        text: 'Your password must be unique and strong.',
                        color: ColorName.grey,
                        fontSize: 14,
                        weight: FontWeight.w400,
                      ),
                      const SizedBox(height: 25),
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
                      const SizedBox(height: 30),
                      _buildPasswordText('Has at least 8 characters'),
                      _buildPasswordText('Has a lowercase letter'),
                      _buildPasswordText('Has an uppercase letter & symbol'),
                      _buildPasswordText('Has a number'),
                      const SizedBox(height: 20),
                      const Divider(
                        color: ColorName.borderColor,
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ButtonWidget(
                    child: const TextWidget(
                      text: 'Set Password',
                      type: TextType.small,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.pushNamed(RouteName.craeteAccount,
                            extra: widget.userModel.copyWith(
                              password: password1Controller.text,
                            ));
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildPasswordText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.check,
            size: 20,
          ),
          const SizedBox(width: 10),
          TextWidget(
            text: text,
            fontSize: 14,
            weight: FontWeight.w400,
          )
        ],
      ),
    );
  }
}
