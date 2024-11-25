import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../gen/assets.gen.dart';
import '../../gen/colors.gen.dart';
import 'button_widget.dart';
import 'text_widget.dart';

class CustomKeyboard extends StatefulWidget {
  final Function(String pins) onComplete;
  final Widget buttonWidget;
  final Function()? onAutoComplete;
  const CustomKeyboard({
    super.key,
    required this.onComplete,
    required this.buttonWidget,
    this.onAutoComplete,
  });

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();

  final pin1Node = FocusNode();
  final pin2Node = FocusNode();
  final pin3Node = FocusNode();
  final pin4Node = FocusNode();
  final pin5Node = FocusNode();
  final pin6Node = FocusNode();

  bool isValid = false;

  getAllPins() {
    String pin1 = pin1Controller.text;
    String pin2 = pin2Controller.text;
    String pin3 = pin3Controller.text;
    String pin4 = pin4Controller.text;
    String pin5 = pin5Controller.text;
    String pin6 = pin6Controller.text;
    if (pin1.isNotEmpty &&
        pin2.isNotEmpty &&
        pin3.isNotEmpty &&
        pin4.isNotEmpty &&
        pin5.isNotEmpty &&
        pin6.isNotEmpty) {
      if (mounted) {
        setState(() {
          isValid = true;
        });
      }
      if (widget.onAutoComplete != null) {
        widget.onAutoComplete!();
      }
    }
    if (mounted) {
      setState(() {
        isValid = false;
      });
    }
    widget.onComplete([pin1, pin2, pin3, pin4, pin5, pin6].join().trim());
  }

  /// Handles the key press event for the PIN code input fields.
  ///
  /// This method is responsible for updating the text in the appropriate PIN code
  /// input field based on the focus state of the input fields. It also requests
  /// focus on the next input field when a value is entered.
  ///
  /// After updating the input fields, it calls the `getAllPins()` method to
  /// retrieve the current values of all the PIN code input fields.
  ///
  /// Parameters:
  /// - `value`: The value of the key that was pressed.
  _onKeyPressed(String value) {
    if (pin1Node.hasFocus) {
      pin1Controller.text = value;
      pin2Node.requestFocus();
    } else if (pin2Node.hasFocus) {
      pin2Controller.text = value;
      pin3Node.requestFocus();
    } else if (pin3Node.hasFocus) {
      pin3Controller.text = value;
      pin4Node.requestFocus();
    } else if (pin4Node.hasFocus) {
      pin4Controller.text = value;
      pin5Node.requestFocus();
    } else if (pin5Node.hasFocus) {
      pin5Controller.text = value;
      pin6Node.requestFocus();
    } else if (pin6Node.hasFocus) {
      pin6Controller.text = value;
      if (pin1Controller.text.isEmpty) {
        pin1Node.requestFocus();
      } else {
        pin6Node.unfocus();
      }
    }

    getAllPins();
  }

  /// Handles the backspace key press event for the PIN code input fields.
  ///
  /// This method is responsible for clearing the text in the appropriate PIN code
  /// input field based on the focus state of the input fields. It also requests
  /// focus on the previous input field when a backspace is pressed.
  ///
  /// After updating the input fields, it calls the `getAllPins()` method to
  /// retrieve the current values of all the PIN code input fields.
  _onBackspace() {
    if (pin1Node.hasFocus) {
      pin1Controller.text = '';
    } else if (pin2Node.hasFocus) {
      pin2Controller.text = '';
      pin1Node.requestFocus();
    } else if (pin3Node.hasFocus) {
      pin3Controller.text = '';
      pin2Node.requestFocus();
    } else if (pin4Node.hasFocus) {
      pin4Controller.text = '';
      pin3Node.requestFocus();
    } else if (pin5Node.hasFocus) {
      pin5Controller.text = '';
      pin4Node.requestFocus();
    } else if (pin6Node.hasFocus) {
      pin6Controller.text = '';
      pin5Node.requestFocus();
    } else {
      pin5Node.requestFocus();
      pin6Controller.text = '';
    }
    getAllPins();
  }

  @override
  void initState() {
    pin1Node.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    pin1Controller.dispose();
    pin2Controller.dispose();
    pin3Controller.dispose();
    pin4Controller.dispose();
    pin5Controller.dispose();
    pin6Controller.dispose();
    pin1Node.dispose();
    pin2Node.dispose();
    pin3Node.dispose();
    pin4Node.dispose();
    pin5Node.dispose();
    pin6Node.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 40),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPinBox(controller: pin1Controller, focusNode: pin1Node),
          _buildPinBox(controller: pin2Controller, focusNode: pin2Node),
          _buildPinBox(controller: pin3Controller, focusNode: pin3Node),
          _buildPinBox(controller: pin4Controller, focusNode: pin4Node),
          _buildPinBox(controller: pin5Controller, focusNode: pin5Node),
          _buildPinBox(controller: pin6Controller, focusNode: pin6Node),
        ],
      ),
      const SizedBox(height: 90),
      widget.buttonWidget,
      const SizedBox(height: 40),
      _buildKeypad(),
    ]);
  }

  // Build the custom numeric keypad
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['4', '5', '6'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['7', '8', '9'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                      child: Icon(
                    Icons.fingerprint_outlined,
                    size: 30,
                  )),
                ),
              ),
              _buildKey('0'),
              GestureDetector(
                onTap: _onBackspace,
                onLongPress: () {
                  pin1Controller.clear();
                  pin2Controller.clear();
                  pin3Controller.clear();
                  pin4Controller.clear();
                  pin5Controller.clear();
                  pin6Controller.clear();
                  pin1Node.requestFocus();
                  getAllPins();
                },
                child: Container(
                  width: 100,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                      child: SvgPicture.asset(
                    Assets.images.svgs.backSpace,
                    width: 30,
                  )),
                ),
              )
            ],
          ),
        ],
      ),
    );
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
              // color: isValid ? Colors.white : Colors.black,
            ),
        textAlign: TextAlign.center,
        readOnly: kIsWeb ? false : true,
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

  // Build each button of the keypad
  Widget _buildKey(String value) {
    return SizedBox(
      width: 105,
      height: 65,
      child: GestureDetector(
        onTap: () => _onKeyPressed(value),
        onVerticalDragStart: (e) => _onKeyPressed(value),
        onHorizontalDragStart: (e) => _onKeyPressed(value),
        child: ButtonWidget(
          elevation: 0,
          horizontalPadding: 0,
          topPadding: 0,
          verticalPadding: 0,
          color: Colors.grey[100],
          onPressed: null,
          child: TextWidget(
            text: value,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}
