import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';

class PincodeScreenDeligate extends StatefulWidget {
  final Function(bool isValid) result;
  final Function(String pincode) onVerified;
  final String? overrideButtonText;

  const PincodeScreenDeligate(
      {super.key,
      required this.result,
      required this.onVerified,
      this.overrideButtonText});

  @override
  State<PincodeScreenDeligate> createState() => _PincodeScreenDeligateState();
}

class _PincodeScreenDeligateState extends State<PincodeScreenDeligate> {
  bool showResendButton = false;
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
  bool isAuthenticated = false;

  String firstPincode = '';

  List<String> getAllPins() {
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

      return [pin1, pin2, pin3, pin4, pin5, pin6];
    }
    if (mounted) {
      setState(() {
        isValid = false;
      });
    }

    return [];
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

    //pincode dispose
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(
              Icons.close,
              size: 30,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SvgPicture.asset(
              Assets.images.svgs.horizontalMelaLogo,
              width: 130,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const TextWidget(
              text: 'Enter Your Pin',
              color: ColorName.primaryColor,
              fontSize: 20,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 5),
            const TextWidget(
              text: 'Enter your pin to confirm your transaction.',
              fontSize: 14,
              color: ColorName.grey,
              weight: FontWeight.w400,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
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
            ),
            const Spacer(),
            ButtonWidget(
                color:
                    isValid ? ColorName.primaryColor : ColorName.grey.shade200,
                child: TextWidget(
                  text: widget.overrideButtonText ?? 'Continue',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isValid) {
                    final pins = getAllPins();
                    widget.onVerified(pins.join());
                    context.pop();
                  }
                }),
            _buildKeypad(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build the custom numeric keypad
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
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

  // Build each button of the keypad
  Widget _buildKey(String value) {
    return SizedBox(
      width: 100,
      height: 60,
      child: ButtonWidget(
        elevation: 0,
        horizontalPadding: 0,
        topPadding: 0,
        verticalPadding: 0,
        color: Colors.grey[100],
        child: TextWidget(
          text: value,
          fontSize: 25,
        ),
        onPressed: () => _onKeyPressed(value),
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
}
