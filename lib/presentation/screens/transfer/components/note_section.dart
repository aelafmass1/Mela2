import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class NoteSection extends StatefulWidget {
  const NoteSection({super.key});

  @override
  State<NoteSection> createState() => NoteSectionState();
}

class NoteSectionState extends State<NoteSection> {
  final noteKey = GlobalKey<FormFieldState>();
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: 'Note',
              fontSize: 14,
              weight: FontWeight.w600,
            ),
            Icon(
              Icons.info_outline,
              color: ColorName.primaryColor,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your note',
            hintStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ColorName.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
