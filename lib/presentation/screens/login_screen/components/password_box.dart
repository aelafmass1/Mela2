import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class PasswordBox extends StatefulWidget {
  final TextEditingController controller;
  const PasswordBox({super.key, required this.controller});

  @override
  State<PasswordBox> createState() => _PasswordBoxState();
}

class _PasswordBoxState extends State<PasswordBox> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        width: ResponsiveUtil.forScreen(
            sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
        margin: EdgeInsets.only(
          top: ResponsiveUtil.forScreen(
              sizingInfo: sizingInfo, mobile: 20, tablet: 50),
        ),
        padding:
            const EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 15),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black87,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Password',
              type: TextType.small,
            ),
            SizedBox(
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is empty';
                  }
                  return null;
                },
                obscureText: isObscure,
                controller: widget.controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: const Color(0xFF4D4D4D).withOpacity(0.5),
                    width: 1,
                  )),
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure
                          ? Icons.remove_red_eye_outlined
                          : Icons.remove_red_eye,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
