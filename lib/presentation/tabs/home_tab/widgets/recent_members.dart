import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';

import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class RecentMembers extends StatelessWidget {
  const RecentMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: 'Recent',
                type: TextType.small,
              ),
              TextButton(
                  onPressed: () {
                    //
                  },
                  child: const TextWidget(
                    text: 'View all',
                    fontSize: 12,
                    color: ColorName.primaryColor,
                  ))
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  children: [
                    IconButton.outlined(
                      color: ColorName.grey,
                      onPressed: () {
                        //
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                    const TextWidget(
                      text: 'Send',
                      fontSize: 8,
                      weight: FontWeight.w400,
                    )
                  ],
                ),
                const SizedBox(width: 5),
                ...List.generate(
                    8,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    Assets.images.profileImage.provider(),
                              ),
                              const TextWidget(
                                text: 'Beza',
                                fontSize: 8,
                                weight: FontWeight.w400,
                                color: ColorName.grey,
                              ),
                              const TextWidget(
                                text: '\$50.00',
                                fontSize: 8,
                                weight: FontWeight.w700,
                              )
                            ],
                          ),
                        ))
              ],
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
