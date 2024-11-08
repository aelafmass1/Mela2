import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class AmountInput extends StatelessWidget {
  final GlobalKey<FormFieldState> amountKey;
  final TextEditingController amountController;
  final String selectedCurrency;

  const AmountInput({
    super.key,
    required this.amountKey,
    required this.amountController,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldWidget(
          globalKey: amountKey,
          controller: amountController,
          keyboardType: TextInputType.number,
          prefixText: '\$',
          suffix: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text(selectedCurrency),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
