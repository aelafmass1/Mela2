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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) => const _TransferModalSheetBody(),
  );
}

class _TransferModalSheetBody extends StatefulWidget {
  const _TransferModalSheetBody();

  @override
  State<_TransferModalSheetBody> createState() =>
      _TransferModalSheetBodyState();
}

class _TransferModalSheetBodyState extends State<_TransferModalSheetBody> {
  ValueNotifier<_TransferToModel?> selectedTransferToModel =
      ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    final transferToItems = [
      _TransferToModel(
          title: "To Other",
          subtitle: "Send money One Of the contact",
          iconPath: Assets.images.svgs.userGroup,
          onTap: () {
            Navigator.pop(context);
            context.pushNamed(RouteName.transferToOther);
          }),
      _TransferToModel(
          title: "To Wallet",
          subtitle: "Withdraw the balance of money to my local bank.",
          iconPath: Assets.images.svgs.wallet02,
          onTap: () {
            Navigator.pop(context);
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
                        const Gap(24),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Transfer To ?',
                              fontSize: 16,
                            ),
                            TextWidget(
                              text:
                                  'Lorem ipsum dolor sit amet consectetur. Non.',
                              fontSize: 13,
                              color: ColorName.grey,
                            ),
                          ],
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(
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
                          border: Border.all(
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
                const SizedBox(height: 10),
                AbsorbPointer(
                  absorbing: selectedTransferToModel.value == null,
                  child: ButtonWidget(
                      color: selectedTransferToModel.value == null
                          ? ColorName.grey.withOpacity(.2)
                          : ColorName.primaryColor,
                      child: const Text("Next"),
                      onPressed: () {
                        selectedTransferToModel.value?.onTap();
                      }),
                )
              ],
            ),
          );
        });
  }
}

class _TransferToModel {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  _TransferToModel(
      {required this.title,
      required this.subtitle,
      required this.iconPath,
      required this.onTap});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TransferToModel &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.iconPath == iconPath;
  }

  @override
  int get hashCode => Object.hash(title, subtitle, iconPath);
}
