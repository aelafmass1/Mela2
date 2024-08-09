import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../widgets/text_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Assets.images.splashLogo.image(
                width: 441,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
              width: 100.sh,
              height: 100,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        //
                      },
                      child: const TextWidget(
                        text: "Next",
                        color: ColorName.primaryColor,
                      )),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorName.primaryColor,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        context.goNamed(RouteName.login);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Assets.images.nextArrow.image(),
                      ),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
