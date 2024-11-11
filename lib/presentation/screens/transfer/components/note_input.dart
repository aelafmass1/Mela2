import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';

class NoteInput extends StatefulWidget {
  final GlobalKey<FormFieldState> noteKey;

  const NoteInput({
    super.key,
    required this.noteKey,
  });

  @override
  NoteInputState createState() => NoteInputState();
}

class NoteInputState extends State<NoteInput> {
  bool validated() {
    if (widget.noteKey.currentState?.validate() == true) {
      return true;
    }
    return false;
  }

  final formKey = GlobalKey<FormFieldState>();
  final noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFieldWidget(
        globalKey: widget.noteKey,
        controller: noteController,
        hintText: 'Add a note',
      ),
    );
  }
}
