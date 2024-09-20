import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubRequestsCard extends StatefulWidget {
  final int index;
  final Function onAccept;

  const EqubRequestsCard({
    required this.index,
    required this.onAccept,
    super.key,
  });

  @override
  State<EqubRequestsCard> createState() => _EqubRequestsCardState();
}

class _EqubRequestsCardState extends State<EqubRequestsCard> {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Member Name ${widget.index}",
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                const SizedBox(
                  height: 5,
                ),
                const TextWidget(
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
          // Checkbox(
          //   value: true,
          //   checkColor: ColorName.green,
          //   fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          //     return ColorName.green.shade100;
          //   }),
          //   side: BorderSide.none,
          //   onChanged: (value) {
          //     // setState(() {
          //     //   isActive = true;
          //     //   isInactive = false;
          //     // });
          //     // Call the onAccept function when this checkbox is clicked
          //     widget.onAccept(widget.index);
          //   },
          // ),
          // Custom Accept "X" checkbox
          GestureDetector(
            onTap: () {
              widget.onAccept(widget.index); // Call the onAccept function
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorName.green,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(1.0),
              child: const Icon(
                Icons.check, // Empty circle when unchecked
                color: ColorName.green,
                size: 15,
              ),
            ),
          ),

          const SizedBox(width: 25),
          // Checkbox(
          //   value: true,
          //   checkColor: ColorName.red,
          //   fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          //     return ColorName.red.shade100;
          //   }),
          //   side: BorderSide.none,
          //   onChanged: (value) {
          //     // setState(() {
          //     //   isInactive = true;
          //     //   isActive = false;
          //     // });
          //     // Call the onAccept function when this checkbox is clicked
          //     widget.onAccept(widget.index);
          //   },
          // ),
          // Custom Reject "X" checkbox
          GestureDetector(
            onTap: () {
              // Call the onAccept function when this checkbox is clicked
              widget.onAccept(widget.index);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorName.red,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(1.0),
              child: const Icon(
                Icons.close, // "X" icon for reject
                color: ColorName.red,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
