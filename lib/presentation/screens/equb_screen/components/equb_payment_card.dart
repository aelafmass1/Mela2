import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/dto/complete_page_dto.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubPaymentCard extends StatefulWidget {
  final int index;
  const EqubPaymentCard({
    required this.index,
    super.key,
  });

  @override
  State<EqubPaymentCard> createState() => _EqubPaymentCardState();
}

class _EqubPaymentCardState extends State<EqubPaymentCard> {
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
          if (!widget.index.isPrime())
            GestureDetector(
              onTap: () => context.pushNamed(
                RouteName.equbActionCompleted,
                extra: CompletePageDto(
                  title: "Reminder sent!",
                  description:
                      "You have successfully sent a reminder to member ${widget.index}!",
                  onComplete: () => context.pop(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorName.white,
                  border: Border.all(
                    color: ColorName.red,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const TextWidget(
                  text: "Remind",
                  fontSize: 13,
                  color: ColorName.red,
                ),
              ),
            ),
          if (!widget.index.isPrime())
            const SizedBox(
              width: 15,
            ),
          Checkbox(
            // value: isActive,
            value: widget.index.isPrime(),
            checkColor: ColorName.green,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
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
            value: !widget.index.isPrime(),
            checkColor: ColorName.red,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
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
