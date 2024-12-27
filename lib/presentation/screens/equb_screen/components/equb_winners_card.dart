import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubWinnersCard extends StatefulWidget {
  final int index;
  final bool isActive;
  const EqubWinnersCard({
    required this.index,
    required this.isActive,
    super.key,
  });

  @override
  State<EqubWinnersCard> createState() => _EqubWinnersCardState();
}

class _EqubWinnersCardState extends State<EqubWinnersCard> {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.isActive ? ColorName.primaryColor : ColorName.white,
              border: Border.all(
                color: ColorName.primaryColor,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextWidget(
              text: widget.isActive ? "Selected" : "Select",
              fontSize: 13,
              color: widget.isActive ? ColorName.white : ColorName.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
