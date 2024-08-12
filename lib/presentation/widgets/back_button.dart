import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';

class BackButtonWidget extends StatelessWidget {
  final EdgeInsets? padding;
  final Function()? onPressed;
  const BackButtonWidget({super.key, this.padding, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 20, bottom: 30),
      child: GestureDetector(
        onTap: onPressed ??
            () {
              context.pop();
            },
        child: Assets.images.backArrow.image(
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
