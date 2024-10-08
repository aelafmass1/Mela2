import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../../../data/models/equb_detail_model.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class EqubCard extends StatelessWidget {
  final EqubDetailModel equb;
  final Function()? onTab;
  final bool showJoinRequestButton;
  final bool onCarousel;
  const EqubCard({
    super.key,
    required this.equb,
    this.onTab,
    this.showJoinRequestButton = false,
    this.onCarousel = false,
  });

  int? getFrequencyDay(String frequency) {
    switch (frequency) {
      case 'WEEKLY':
        return 7;
      case 'BIWEEKLY':
        return 15;
      case 'MONTHLY':
        return 30;
      default:
        return null;
    }
  }

  /// Calculates the remaining number of days until the next Equb payment is due.
  ///
  /// This method retrieves the start date of the Equb, the frequency of the Equb
  /// (in days), and the current day. It then calculates the number of days
  /// remaining until the next payment is due.
  ///
  /// Returns the number of days remaining, or `null` if the frequency could not
  /// be determined.

  int? getRemainingDate() {
    final startDate = equb.startDate;
    final freqencyInDay = getFrequencyDay(equb.frequency);
    if (freqencyInDay == null) return null;
    final endDay = startDate.day + freqencyInDay;
    final currentDay = DateTime.now().day;

    return endDay - currentDay;
  }

  @override
  Widget build(BuildContext context) {
    final remainingDay = getRemainingDate();
    return GestureDetector(
      onTap: onTab ??
          () {
            context.pushNamed(
              RouteName.equbAdminDetail,
              extra: equb,
            );
          },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(15),
        width: onCarousel ? 93.sw : 100.sw,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              offset: const Offset(-2, -2),
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00D2FF),
                    Color(0xFF3A7BD5),
                  ],
                ),
              ),
              child: Center(
                child: TextWidget(
                  text: equb.name.split(' ').length == 1
                      ? equb.name.split('').first.toUpperCase()
                      : equb.name
                          .trim()
                          .split(' ')
                          .take(3)
                          .map((e) => e[0])
                          .join()
                          .toUpperCase(),
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 70.sw,
                  child: TextWidget(
                    text: equb.name,
                    fontSize: 16,
                  ),
                ),
                const TextWidget(
                  text: 'Created at 12-02-2024',
                  fontSize: 10,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: 1,
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: 'Contribution Amount',
                            fontSize: 10,
                            weight: FontWeight.w400,
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: 20.sw,
                            child: TextWidget(
                              text: 'ETB ${equb.contributionAmount}',
                              fontSize: 12,
                              color: ColorName.primaryColor,
                              weight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 8, left: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: 1,
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: 'Total Amount',
                            fontSize: 10,
                            weight: FontWeight.w400,
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: 20.sw,
                            child: TextWidget(
                              text:
                                  'ETB ${equb.contributionAmount * equb.numberOfMembers}',
                              fontSize: 12,
                              color: ColorName.primaryColor,
                              weight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: 'End Date',
                            fontSize: 10,
                            weight: FontWeight.w400,
                          ),
                          const SizedBox(height: 3),
                          TextWidget(
                            text:
                                '${(equb.startDate.day + (getFrequencyDay(equb.frequency) ?? 0)).toString().padLeft(2, '0')}-${equb.startDate.month.toString().padLeft(2, '0')}-${equb.startDate.year}',
                            fontSize: 14,
                            color: ColorName.primaryColor,
                            weight: FontWeight.bold,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 70.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50.sw,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            for (int i = 0;
                                i <
                                    equb.members
                                        .where((e) =>
                                            (e.user?.firstName != null) &&
                                            e.user?.lastName != null)
                                        .length;
                                i++)
                              if (i < 5)
                                _buildEqubMember(
                                    '${equb.members[i].user?.firstName?.trim() ?? ''} ${equb.members[i].user?.lastName?.trim() ?? ''}',
                                    i),
                          ],
                        ),
                      ),
                      if (showJoinRequestButton)
                        SizedBox(
                          width: 75,
                          height: 30,
                          child: ButtonWidget(
                              horizontalPadding: 5,
                              verticalPadding: 0,
                              child: const TextWidget(
                                text: 'Request Join',
                                type: TextType.small,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              onPressed: () {}),
                        )
                      else if (remainingDay == 0)
                        SizedBox(
                          width: 75,
                          height: 30,
                          child: ButtonWidget(
                              color: ColorName.yellow,
                              horizontalPadding: 5,
                              verticalPadding: 0,
                              child: const TextWidget(
                                text: 'Make Payment',
                                type: TextType.small,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              onPressed: () {}),
                        )
                      else
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: SimpleCircularProgressBar(
                            valueNotifier:
                                ValueNotifier(remainingDay?.toDouble() ?? 0),
                            progressStrokeWidth: 3,
                            backStrokeWidth: 3,
                            maxValue: (getFrequencyDay(equb.frequency) ?? 0)
                                .toDouble(),
                            animationDuration: 3,
                            mergeMode: true,
                            onGetText: (value) {
                              return Text(
                                '${value.toInt()}\nDays',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontSize: 10,
                                    ),
                              );
                            },
                            progressColors: [
                              ((remainingDay ?? 0) <= 3)
                                  ? ColorName.red
                                  : ColorName.primaryColor,
                            ],
                            backColor: Colors.black.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildEqubMember(String contactName, int index) {
    return Visibility(
      visible: contactName.isNotEmpty,
      child: Positioned(
        left: index * 22,
        child: Container(
          clipBehavior: Clip.antiAlias,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: ColorName.primaryColor,
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 2,
                ),
              ]),
          child:
              //  contact.photo != null
              //     ? Image.memory(
              //         contact.photo!,
              //         fit: BoxFit.cover,
              //       )
              Center(
            child: TextWidget(
              text: contactName.trim().isEmpty
                  ? ''
                  : contactName.trim().split(' ').map((n) => n[0]).join(),
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
