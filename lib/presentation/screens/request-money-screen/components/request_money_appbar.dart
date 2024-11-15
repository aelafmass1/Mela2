import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';

import '../../../widgets/text_widget.dart';

class AppBarWithNoDropdown extends StatefulWidget {
  const AppBarWithNoDropdown({
    super.key,
  });

  @override
  State<AppBarWithNoDropdown> createState() => AppBarWithNoDropdownState();
}

class AppBarWithNoDropdownState extends State<AppBarWithNoDropdown> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text: 'Request Money',
            fontSize: 15,
            weight: FontWeight.bold,
          ),
        ],
      ),
      leading: IconButton(
        icon: SvgPicture.asset(Assets.images.svgs.backArrow),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
