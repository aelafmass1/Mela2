import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class SearchCancelInput extends StatelessWidget {
  const SearchCancelInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(3, 2),
          ),
        ],
        color: ColorName.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 20,
          ),
          SvgPicture.asset(Assets.images.svgs.search),
          const SizedBox(
            width: 20,
          ),
          const Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.pop(
                null,
              );
            },
            child: Container(
              height: 60,
              width: 100,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 3,
                    offset: const Offset(3, 4),
                  ),
                ],
                color: ColorName.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: TextWidget(
                  text: 'Cancel',
                  color: ColorName.primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
