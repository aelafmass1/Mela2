import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ReceitPage extends StatelessWidget {
  const ReceitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
                child: Container(
              color: Colors.amber,
            )),
            const SizedBox(height: 20),
            ButtonWidget(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Bootstrap.download,
                      size: 20,
                    ),
                    SizedBox(width: 20),
                    TextWidget(
                      text: 'Download Receipt',
                      type: TextType.small,
                      color: Colors.white,
                    ),
                  ],
                ),
                onPressed: () {
                  //
                }),
            const SizedBox(height: 15),
            SizedBox(
              width: 100.sw,
              height: 55,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const TextWidget(
                    text: 'Finish',
                    type: TextType.small,
                    color: ColorName.primaryColor,
                  ),
                  onPressed: () {
                    context.pop();
                  }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
