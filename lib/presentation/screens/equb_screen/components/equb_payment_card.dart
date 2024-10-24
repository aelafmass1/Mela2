import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/dto/complete_page_dto.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubPaymentCard extends StatefulWidget {
  final EqubInviteeModel equbInviteeModel;
  final int index;
  const EqubPaymentCard({
    required this.index,
    required this.equbInviteeModel,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: widget.equbInviteeModel.name,
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                const SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text: widget.equbInviteeModel.phoneNumber,
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
          if (!isActive)
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorName.white,
                  border: Border.all(
                    color: ColorName.red,
                  ),
                  borderRadius: BorderRadius.circular(30),
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
            value: isActive,
            checkColor: ColorName.green,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return ColorName.green.shade100;
            }),
            side: BorderSide.none,
            onChanged: (value) {
              setState(() {
                isActive = true;
              });
            },
          ),
          Checkbox(
            value: !isActive,
            checkColor: ColorName.red,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return ColorName.red.shade100;
            }),
            side: BorderSide.none,
            onChanged: (value) {
              setState(() {
                isActive = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
