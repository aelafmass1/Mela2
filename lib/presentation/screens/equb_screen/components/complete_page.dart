import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class CompletePage extends StatelessWidget {
  const CompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 100.sw,
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            SvgPicture.asset(Assets.images.svgs.cameraIcon),
            const SizedBox(height: 20),
            const TextWidget(
              text: 'Completed',
              fontSize: 24,
              color: ColorName.primaryColor,
            ),
            const SizedBox(height: 10),
            const TextWidget(
              text: 'You have successfully Joined  “Name Equb”',
              color: Color(0xFF6D6D6D),
              fontSize: 14,
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: ButtonWidget(
                  child: const TextWidget(
                    text: 'Done',
                    color: Colors.white,
                    type: TextType.small,
                  ),
                  onPressed: () {
                    context.pop();
                    context.pop();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
