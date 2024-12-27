import 'package:flutter/material.dart';

import '../../../../gen/colors.gen.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/text_widget.dart';

class BuildTitleButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final Color color;

  const BuildTitleButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 25,
      child: ButtonWidget(
        topPadding: 0,
        verticalPadding: 0,
        horizontalPadding: 0,
        borderRadius: BorderRadius.circular(5),
        color: color,
        onPressed: onPressed,
        child: TextWidget(
          text: text,
          color: ColorName.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
