import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../../../data/models/equb_detail_model.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class EqubCard extends StatelessWidget {
  final EqubDetailModel equb;
  const EqubCard({
    super.key,
    required this.equb,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      width: 100.sw,
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
                    : equb.name.split(' ').map((e) => e[0]).join().toUpperCase(),
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: equb.name,
                fontSize: 16,
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
                            text: 'ETB ${equb.contributionAmount * equb.numberOfMembers}',
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
                          text: '${equb.startDate.day}-${equb.startDate.month}-${equb.startDate.year}',
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
              Row(
                children: [
                  SizedBox(
                    width: 50.sw,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        for (int i = 0; i < equb.invitees.length; i++)
                          if (i < 5) _buildEqubMember(equb.invitees[i], i),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 20.sw,
                    child: ButtonWidget(
                      verticalPadding: 7.5,
                      child: const Text("Status"),
                      onPressed: () => context.pushNamed(
                        RouteName.equbDetail,
                        extra: equb,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _buildEqubMember(EqubInviteeModel contact, int index) {
    return Positioned(
      left: index * 22,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: 30,
        height: 30,
        decoration:
            BoxDecoration(color: ColorName.primaryColor, borderRadius: BorderRadius.circular(100), boxShadow: const [
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
            text: contact.name.isEmpty ? '' : contact.name.split(' ').map((n) => n[0]).join(),
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
