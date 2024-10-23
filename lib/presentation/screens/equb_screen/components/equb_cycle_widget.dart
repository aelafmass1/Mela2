import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/equb_cycle_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubCycleWidget extends StatelessWidget {
  final EqubCycleModel equbCycleModel;
  const EqubCycleWidget({super.key, required this.equbCycleModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 32,
      margin: const EdgeInsets.only(right: 25),
      decoration: BoxDecoration(
          color: equbCycleModel.status == 'CURRENT'
              ? ColorName.primaryColor
              : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          border: equbCycleModel.status == 'CURRENT'
              ? const Border(bottom: BorderSide(color: Colors.black, width: 2))
              : null),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: equbCycleModel.status == 'CURRENT'
                  ? ColorName.white
                  : equbCycleModel.status == 'FUTURE'
                      ? null
                      : const Color(0xFFD0D0D0),
              border: equbCycleModel.status == 'CURRENT'
                  ? null
                  : Border.all(color: const Color(0xFFD0D0D0)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextWidget(
                  text: '${equbCycleModel.cycleNumber}',
                  fontSize: 10,
                  weight: FontWeight.w600,
                  color: equbCycleModel.status == 'CURRENT'
                      ? ColorName.primaryColor
                      : equbCycleModel.status == 'FUTURE'
                          ? ColorName.grey
                          : Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          TextWidget(
            text: 'Cycle',
            fontSize: 8,
            color: equbCycleModel.status == 'CURRENT'
                ? ColorName.white
                : ColorName.grey,
          )
        ],
      ),
    );
  }
}
