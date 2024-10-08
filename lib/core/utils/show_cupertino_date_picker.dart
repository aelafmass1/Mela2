import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

/// Shows a Cupertino date picker in a modal bottom sheet.
///
/// This function displays a Cupertino date picker in a modal bottom sheet, allowing the user to select a date. The selected date is returned as a [DateTime] object.
///
/// The date picker is initialized with the current date and time, and the user can select a date between the current date and the year 2500.
///
/// The bottom sheet also includes a "Select Date" button that dismisses the bottom sheet and returns the selected date.
///
/// Parameters:
/// - `context`: The [BuildContext] of the current widget tree, used to display the modal bottom sheet.
///
/// Returns:
/// A [Future<DateTime?>] that completes with the selected date, or `null` if the user dismisses the bottom sheet without selecting a date.
Future<DateTime?> showCupertinoDatePicker(
  BuildContext context,
) async {
  DateTime? selectedDate = DateTime.now();
  await showModalBottomSheet(
    context: context,
    builder: (BuildContext builder) {
      return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        height: 43.sh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 20, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextWidget(
                    text: 'Starting Date',
                    type: TextType.small,
                  ),
                  IconButton(
                    onPressed: () {
                      selectedDate = null;
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: ColorName.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                minimumDate: DateTime.now(),
                maximumDate: DateTime(2500),
                initialDateTime: DateTime.now(),
                itemExtent: 30,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  selectedDate = newDate;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: ButtonWidget(
                  child: const TextWidget(
                    text: 'Select Date',
                    type: TextType.small,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.pop();
                  }),
            )
          ],
        ),
      );
    },
  );
  return selectedDate;
}
