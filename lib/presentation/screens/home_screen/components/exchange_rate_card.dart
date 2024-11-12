import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../../../data/models/curruncy_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../widgets/text_widget.dart';

class ExchangeRateCard extends StatelessWidget {
  final CurrencyModel currencyModel;
  const ExchangeRateCard({super.key, required this.currencyModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorName.borderColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeft(),
          _buildRight(),
        ],
      ),
    );
  }

  _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundImage: Assets.images.usaFlag.provider(),
            ),
            const SizedBox(width: 7),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: currencyModel.currencyCode,
                  fontSize: 8,
                  weight: FontWeight.w500,
                  color: ColorName.primaryColor,
                ),
                TextWidget(
                  text: '1 ${currencyModel.currencyCode}',
                  fontSize: 12,
                  color: ColorName.primaryColor,
                )
              ],
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundImage: Assets.images.ethiopianFlag.provider(),
            ),
            const SizedBox(width: 7),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  text: 'ET Birr',
                  fontSize: 8,
                  weight: FontWeight.w500,
                  color: ColorName.primaryColor,
                ),
                TextWidget(
                  text: '${currencyModel.rate} ETB',
                  fontSize: 12,
                  color: ColorName.primaryColor,
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  _buildRight() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: ColorName.borderColor,
            ),
          ),
          child: Row(
            children: [
              const TextWidget(
                text: 'CBE',
                fontSize: 8,
              ),
              const SizedBox(width: 5),
              Assets.images.cbeLogo.image(
                width: 14,
                height: 14,
              ),
            ],
          ),
        ),
        TextWidget(
          text: '${currencyModel.rate} ETB',
          fontSize: 14,
        ),
        Row(
          children: [
            SvgPicture.asset(
              Assets.images.svgs.increaseArrow,
              width: 8,
              height: 8,
            ),
            const SizedBox(width: 5),
            const TextWidget(
              text: '+ 2.5%',
              fontSize: 10,
            )
          ],
        )
      ],
    );
  }
}
