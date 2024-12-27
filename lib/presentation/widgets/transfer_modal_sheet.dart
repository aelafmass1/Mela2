import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import 'card_widget.dart';
import 'text_widget.dart';

showTransferModalSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFDFDFD),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) => TransferModalSheetBody(),
  ); 
}

class TransferModalSheetBody extends StatelessWidget {
  TransferModalSheetBody({super.key});

  ValueNotifier<TransferToModel?> selectedTransferToModel = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final transferToItems = [
      TransferToModel(
          title: "To Other",
          subtitle: "Send money One Of the contact",
          iconPath: Assets.images.svgs.userGroup,
          onTap: () {
            context.pop();
            context.pushNamed(
              RouteName.transferToOther,
              extra: false,
            );
          }),
      TransferToModel(
          title: "To Wallet",
          subtitle: "Withdraw the balance of money to my local bank.",
          iconPath: Assets.images.svgs.wallet02,
          onTap: () {
            context.pop();

            context.pushNamed(RouteName.transferToWallet);
          })
    ];
    return ValueListenableBuilder(
        valueListenable: selectedTransferToModel,
        builder: (context, _, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Transfer To ?',
                              fontSize: 16,
                              weight: FontWeight.w700,
                            ),
                            TextWidget(
                              text:
                                  'Lorem ipsum dolor sit amet consectetur. Non.',
                              fontSize: 10,
                              color: ColorName.grey,
                            ),
                          ],
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            elevation: 20,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(16),
                ...transferToItems.map(
                  (e) {
                    final isSelected = selectedTransferToModel.value == e;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          selectedTransferToModel.value = e;
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: CardWidget(
                          boxBorder: Border.all(
                            color: isSelected
                                ? ColorName.primaryColor
                                : Colors.transparent,
                          ),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(100),
                                      border:
                                          Border.all(color: ColorName.grey)),
                                  child: SvgPicture.asset(e.iconPath),
                                ),
                              ),
                              title: TextWidget(
                                text: e.title,
                                fontSize: 16,
                              ),
                              subtitle: TextWidget(
                                text: e.subtitle,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                AbsorbPointer(
                  absorbing: selectedTransferToModel.value == null,
                  child: ButtonWidget(
                      onPressed: selectedTransferToModel.value == null
                          ? null
                          : () {
                              selectedTransferToModel.value?.onTap();
                            },
                      child: const TextWidget(
                        text: "Next",
                        color: Colors.white,
                        type: TextType.small,
                      )),
                )
              ],
            ),
          );
        });
  }
}

class TransferToModel {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  TransferToModel(
      {required this.title,
      required this.subtitle,
      required this.iconPath,
      required this.onTap});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransferToModel &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.iconPath == iconPath;
  }

  @override
  int get hashCode => Object.hash(title, subtitle, iconPath);
}
