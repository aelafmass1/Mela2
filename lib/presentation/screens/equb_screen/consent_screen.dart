import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../../gen/colors.gen.dart';
import '../../widgets/text_widget.dart';

class ConsentScreen extends StatefulWidget {
  final Function(bool isValid) result;
  const ConsentScreen({super.key, required this.result});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool isAgreed = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.result(isAgreed);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          leading: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: IconButton(
              onPressed: () {
                isAgreed = false;
                context.pop();
              },
              icon: const Icon(
                Icons.close,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(text: 'Consent'),
              const SizedBox(
                height: 20,
              ),
              _buildTermAndCondition(),
              const Expanded(child: SizedBox()),
              ButtonWidget(
                onPressed: isAgreed
                    ? () {
                        context.pop();
                      }
                    : null,
                child: const TextWidget(
                  text: 'Next',
                  type: TextType.small,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  _buildTermAndCondition() {
    return Column(
      children: [
        Container(
          width: 100.sw,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                offset: const Offset(-2, -2),
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Terms and Conditions',
                  fontSize: 16,
                ),
                SizedBox(height: 10),
                TextWidget(
                  text:
                      'Lorem ipsum dolor sit amet consectetur. Nullam imperdiet habitant nunc neque molestie tristique. Sed pulvinar lectus pharetra elit. Commodo lacus ipsum egestas penatibus velit amet. Viverra sit hendrerit tempus maecenas eu fusce turpis quam turpis. Nunc eleifend felis iaculis nibh blandit sit. Convallis interdum et et elit malesuada morbi euismod dolor viverra. Pretium facilisi sed mattis aliquet dapibus porttitor purus maecenas pellentesque. Ultrices id consectetur leo donec fringilla integer in. Lacinia neque quisque sit metus neque proin justo. Id nascetur nisi eget et varius in vivamus dolor. Leo vitae id eu enim sit eget. Sed felis sit nibh rhoncus hendrerit.\n\nLorem ipsum dolor sit amet consectetur. Nullam imperdiet habitant nunc neque molestie tristique. Sed pulvinar lectus pharetra elit. Commodo lacus ipsum egestas penatibus velit amet. Viverra sit hendrerit tempus maecenas eu fusce turpis quam turpis. Nunc eleifend felis iaculis nibh blandit sit. Convallis interdum et et elit malesuada morbi euismod dolor viverra. Pretium facilisi sed mattis aliquet dapibus porttitor purus maecenas pellentesque. Ultrices id consectetur leo donec fringilla integer in.',
                  color: Color(0xFF6D6D6D),
                  fontSize: 14,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
                shape: const CircleBorder(),
                activeColor: ColorName.primaryColor,
                value: isAgreed,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      isAgreed = value;
                    });
                  }
                }),
            GestureDetector(
              onTap: () {
                setState(() {
                  isAgreed = !isAgreed;
                });
              },
              child: const TextWidget(
                text: 'Yes, I agree to the terms and Conditions.',
                type: TextType.small,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}
