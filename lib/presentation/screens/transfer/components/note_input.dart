import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

class NoteInput extends StatelessWidget {
  final GlobalKey<FormFieldState> noteKey;
  final TextEditingController noteController;

  const NoteInput({
    super.key,
    required this.noteKey,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldWidget(
      globalKey: noteKey,
      controller: noteController,
      hintText: 'Add a note',
    );
  }
}
