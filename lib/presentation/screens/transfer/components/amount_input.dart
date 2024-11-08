// import 'package:flutter/material.dart';
// import 'package:transaction_mobile_app/gen/colors.gen.dart';
// import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
// import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

// class AmountInput extends StatelessWidget {
//   final GlobalKey<FormFieldState> amountKey;
//   final TextEditingController amountController;
//   final String selectedCurrency;

//   const AmountInput({
//     super.key,
//     required this.amountKey,
//     required this.amountController,
//     required this.selectedCurrency,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             TextFieldWidget(
//               globalKey: amountKey,
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               prefixText: '\$',
//             ),
//             DropdownButton<String>(
//               value: selectedCurrency,
//               onChanged: (String? value) {
//                 // Handle currency selection
//               },
//               items: const [
//                 DropdownMenuItem(
//                   value: 'USD',
//                   child: Text('USD'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'EUR',
//                   child: Text('EUR'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'GBP',
//                   child: Text('GBP'),
//                 ),
//               ],
//               icon: const Icon(Icons.arrow_drop_down),
//               underline: Container(),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
