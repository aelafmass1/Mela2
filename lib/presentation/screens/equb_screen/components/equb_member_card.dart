import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubMemberCard extends StatefulWidget {
  final int index;
  const EqubMemberCard({
    required this.index,
    super.key,
  });

  @override
  State<EqubMemberCard> createState() => _EqubMemberCardState();
}

class _EqubMemberCardState extends State<EqubMemberCard> {
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
          if (widget.index.isPrime())
            const Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: ColorName.yellow,
                ),
                SizedBox(
                  width: 5,
                ),
                TextWidget(
                  text: "Pending",
                  fontSize: 13,
                  color: ColorName.yellow,
                )
              ],
            ),
          if (!widget.index.isPrime() && widget.index.isOdd)
            const Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: ColorName.primaryColor,
                ),
                SizedBox(
                  width: 5,
                ),
                TextWidget(
                  text: "Joined",
                  fontSize: 13,
                  color: ColorName.primaryColor,
                )
              ],
            ),
          if (!widget.index.isPrime() && widget.index.isEven)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorName.primaryColor,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const TextWidget(
                text: "Invite",
                fontSize: 13,
                color: ColorName.primaryColor,
              ),
            ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.more_vert_rounded),
          // ),
        ],
      ),
    );
  }
}
