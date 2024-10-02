import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../gen/assets.gen.dart';
import 'button_widget.dart';
import 'text_widget.dart';

class KeypadWidget extends StatefulWidget {
  const KeypadWidget(
      {super.key, required this.onBackPressed, required this.onKeyPressed});
  final Function(String key) onKeyPressed;
  final Function() onBackPressed;
  @override
  State<KeypadWidget> createState() => _KeypadWidgetState();
}

class _KeypadWidgetState extends State<KeypadWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildKeypad();
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
                onTap: widget.onBackPressed,
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
        onPressed: () => widget.onKeyPressed(value),
      ),
    );
  }
}
