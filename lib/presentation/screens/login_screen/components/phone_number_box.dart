import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class PhoneNumberBox extends StatefulWidget {
  final TextEditingController controller;
  const PhoneNumberBox({super.key, required this.controller});

  @override
  State<PhoneNumberBox> createState() => _PhoneNumberBoxState();
}

class _PhoneNumberBoxState extends State<PhoneNumberBox> {
  String country = 'usa';
  String countryCode = '+1';

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        clipBehavior: Clip.antiAlias,
        width: ResponsiveUtil.forScreen(
            sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.black87,
          ),
        ),
        child: Column(
          children: [
            DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 13),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                  ),
                ),
                value: country,
                items: [
                  DropdownMenuItem(
                      value: 'usa',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          children: [
                            Assets.images.usaFlag.image(
                              width: 49,
                              height: 28,
                            ),
                            const SizedBox(width: 15),
                            const TextWidget(
                              text: 'United State',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      )),
                  DropdownMenuItem(
                    value: 'ethiopia',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Row(
                        children: [
                          Assets.images.ethiopianFlag.image(
                            width: 49,
                            height: 28,
                          ),
                          const SizedBox(width: 15),
                          const TextWidget(
                            text: 'Ethiopia',
                            type: TextType.small,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      country = value;
                    });
                    if (country == 'usa') {
                      setState(() {
                        countryCode = '+1';
                      });
                    } else if (country == 'ethiopia') {
                      setState(() {
                        countryCode = '+251';
                      });
                    }
                  }
                }),
            const Divider(
              color: Color(0xff4d4d4d80),
              height: 1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    countryCode,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                Container(
                  width: 1,
                  color: const Color(0xff4d4d4d80),
                  height: 30,
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone number is empty!';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      contentPadding: EdgeInsets.symmetric(horizontal: 13),
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }
}
