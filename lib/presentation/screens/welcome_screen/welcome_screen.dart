import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Assets.images.doodles.image(
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 15),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ColorName.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: SvgPicture.asset(
              Assets.images.svgs.melaLogo,
              width: 52,
            )),
          ),
          const SizedBox(height: 25),
          const TextWidget(
            text: 'Welcome to Mela',
            color: ColorName.primaryColor,
            fontSize: 24,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80.sw,
            child: const TextWidget(
              text:
                  'Empowering the Ethiopian dispora with modern finacial solution',
              textAlign: TextAlign.center,
              fontSize: 14,
              weight: FontWeight.w400,
              color: Color(0xFf6D6D6D),
            ),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            child: ButtonWidget(
                child: const TextWidget(
                  text: 'Get Started',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.goNamed(
                    RouteName.signup,
                  );
                }),
          )
        ],
      ),
    );
  }
}
