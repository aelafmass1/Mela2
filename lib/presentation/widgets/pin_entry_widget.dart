import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

class PinEntryWidget extends StatefulWidget {
  final int pinLength;

  const PinEntryWidget({super.key, this.pinLength = 6});

  /// Overrides a method in the superclass to provide custom implementation.
  ///
  /// This method is part of the widget lifecycle and is called by the framework
  /// when the widget needs to update its state or perform other operations.
  @override
  createState() => PinEntryWidgetState();
}

class PinEntryWidgetState extends State<PinEntryWidget> {
  late List<TextEditingController> pinControllers;
  late List<FocusNode> pinFocusNodes;

  @override
  void initState() {
    super.initState();
    pinControllers =
        List.generate(widget.pinLength, (_) => TextEditingController());
    pinFocusNodes = List.generate(widget.pinLength, (_) => FocusNode());
  }

  void clearAll() {
    for (var element in pinControllers) {
      element.clear();
    }
    // focus the first node .
    pinFocusNodes.first.requestFocus();
  }

  void addPin(String pin) {
    for (var i = 0; i < pinControllers.length; i++) {
      if (pinControllers[i].text.isEmpty) {
        pinControllers[i].text = pin;
        break;
      }
    }
    // focus on the next pin
    for (var i = 0; i < pinFocusNodes.length; i++) {
      if (pinControllers[i].text.isEmpty) {
        pinFocusNodes[i].requestFocus();
        break;
      }
    }
  }

  List<String> getAllPins() {
    final pins = pinControllers.where((e) => e.value.text.isNotEmpty).map((e) {
      return e.text;
    }).toList();
    return pins;
  }

  void clearLast() {
    // Clear the last pin
    for (var i = pinControllers.length - 1; i >= 0; i--) {
      if (pinControllers[i].text.isNotEmpty) {
        pinControllers[i].clear();

        break;
      }
    }
    // Focus on the last non empty pin
    for (var i = pinControllers.length - 1; i >= 0; i--) {
      if (pinControllers[i].text.isNotEmpty) {
        pinFocusNodes[i].requestFocus();
        break;
      }
    }
  }

  Widget _buildPinBox(
      {required TextEditingController controller,
      required FocusNode focusNode}) {
    return SizedBox(
      height: 70,
      width: 13.sw,
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          getAllPins();
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: ColorName.primaryColor,
            ),
        textAlign: TextAlign.center,
        readOnly: true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          LengthLimitingTextInputFormatter(1),
        ],
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
                width: 2,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(widget.pinLength, (index) {
        return _buildPinBox(
          controller: pinControllers[index],
          focusNode: pinFocusNodes[index],
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in pinControllers) {
      controller.dispose();
    }
    for (var focusNode in pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
