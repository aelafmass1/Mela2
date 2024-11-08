import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class SearchBtn extends StatelessWidget {
  const SearchBtn({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: onTap,
          child: CardWidget(
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.svgs.search),
                    const SizedBox(width: 12),
                    const TextWidget(
                      text: 'Search by @username , name or phone number',
                      fontSize: 14,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
