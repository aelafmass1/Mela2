import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubRequestsCard extends StatefulWidget {
  final int index;
  const EqubRequestsCard({
    required this.index,
    super.key,
  });

  @override
  State<EqubRequestsCard> createState() => _EqubRequestsCardState();
}

class _EqubRequestsCardState extends State<EqubRequestsCard> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 50,
              height: 50,
              color: ColorName.primaryColor,
              alignment: Alignment.center,
              child: const TextWidget(
                text: "",
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Member Name",
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text: "+251912345678",
                  type: TextType.small,
                  fontSize: 14,
                  weight: FontWeight.w300,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Checkbox(
            value: isActive,
            checkColor: ColorName.green,
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              return ColorName.green.shade100;
            }),
            side: BorderSide.none,
            onChanged: (value) {
              setState(() {
                isActive = !isActive;
              });
            },
          ),
          Checkbox(
            value: !isActive,
            checkColor: ColorName.red,
            fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              return ColorName.red.shade100;
            }),
            side: BorderSide.none,
            onChanged: (value) {
              setState(() {
                isActive = !isActive;
              });
            },
          ),
        ],
      ),
    );
  }
}
