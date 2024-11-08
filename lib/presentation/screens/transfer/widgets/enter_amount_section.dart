import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../gen/assets.gen.dart';

class EnterAmountSection extends StatefulWidget {
  const EnterAmountSection({super.key});

  @override
  State<EnterAmountSection> createState() => _EnterAmountSectionState();
}

class _EnterAmountSectionState extends State<EnterAmountSection> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: 'Enter Amount',
          fontSize: 18,
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ColorName.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage(Assets.images.usaFlag.path),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: ColorName.grey),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            hintText: '0.00',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: ColorName.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
