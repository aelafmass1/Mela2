import 'package:flutter/material.dart';

import '../../widgets/text_field_widget.dart';
import '../../widgets/text_widget.dart';

class PasswordEditScreen extends StatefulWidget {
  const PasswordEditScreen({super.key});

  @override
  State<PasswordEditScreen> createState() => _PasswordEditScreenState();
}

class _PasswordEditScreenState extends State<PasswordEditScreen> {
  final currentPassword = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConfirmController = TextEditingController();

  bool currentPassowordObscure = true;
  bool newPasswordObscure = true;
  bool confirmPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
          text: 'Password',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 5),
              child: TextWidget(
                text: 'Current Passoword',
                fontSize: 12,
              ),
            ),
            TextFieldWidget(
              controller: currentPassword,
              hintText: 'Enter your current password',
              obscurePassword: currentPassowordObscure,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    currentPassowordObscure = !currentPassowordObscure;
                  });
                },
                icon: Icon(
                  currentPassowordObscure
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye,
                  size: 20,
                ),
              ),
            ),
            // ButtonWidget(child: TextWidget(text: ''), onPressed: onPressed)
          ],
        ),
      ),
    );
  }
}
