import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../../../data/models/curruncy_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../widgets/text_widget.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashLength;
  final double dashSpace;

  DashedLinePainter({
    this.color = Colors.amber,
    this.dashLength = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashLength),
        paint,
      );
      startY += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

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
    return Stack(
      children: [
        Positioned(
          left: 10,
          top: 9,
          child: CustomPaint(
            size: const Size(1, 65),
            painter: DashedLinePainter(
              color: ColorName.grey,
              dashLength: 2,
              dashSpace: 3,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'icons/currency/${currencyModel.currencyCode.toLowerCase()}.png',
                    package: 'currency_icons',
                    fit: BoxFit.cover,
                  ),
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
        ),
      ],
    );
  }

  _buildRight() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextWidget(
          text: '${currencyModel.rate} ETB',
          fontSize: 14,
          color: ColorName.primaryColor,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
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
