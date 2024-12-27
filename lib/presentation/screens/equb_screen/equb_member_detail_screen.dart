
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/data/models/equb_detail_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';

import '../../../core/utils/show_consent.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/text_widget.dart';

class EqubMemberDetailScreen extends StatefulWidget {
  final EqubDetailModel equbDetailModel;
  const EqubMemberDetailScreen({super.key, required this.equbDetailModel});

  @override
  State<EqubMemberDetailScreen> createState() => _EqubMemberDetailScreenState();
}

class _EqubMemberDetailScreenState extends State<EqubMemberDetailScreen> {
  bool isPending = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: ColorName.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTop(),
                  _buildMembers(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: ButtonWidget(
                  onPressed: isPending
                      ? null
                      : () async {
                          final agreed = await showConsent(context);
                          if (agreed) {
                            setState(() {
                              isPending = true;
                            });
                            showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: ((_) => Dialog(
                                      child: Container(
                                        width: 100.sw,
                                        height: 55.sh,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 40),
                                            SvgPicture.asset(Assets
                                                .images.svgs.completeLogo),
                                            const SizedBox(height: 20),
                                            const TextWidget(
                                              text: 'Request Sent',
                                              color: ColorName.primaryColor,
                                              fontSize: 24,
                                            ),
                                            const SizedBox(height: 20),
                                            TextWidget(
                                              text:
                                                  'You have successfully sent a request to join “${widget.equbDetailModel.name}”',
                                              color: ColorName.grey,
                                              textAlign: TextAlign.center,
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )));
                          }
                        },
                  child: TextWidget(
                    text: isPending ? 'Pending' : 'Request to Join',
                    type: TextType.small,
                    color: Colors.white,
                  )),
            )
          ],
        ),
      ),
    );
  }

  _buildTop() {
    return Container(
      width: 100.sw,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: ColorName.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4776E6),
                        Color(0xFF8E54E9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: widget.equbDetailModel.name.isNotEmpty
                        ? TextWidget(
                            text: widget.equbDetailModel.name
                                        .trim()
                                        .split(' ')
                                        .length ==
                                    1
                                ? widget.equbDetailModel.name
                                    .split('')
                                    .first
                                    .trim()
                                : '${widget.equbDetailModel.name.trim().split(' ').first[0]}${widget.equbDetailModel.name.trim().split(' ').last[0]}',
                            color: Colors.white,
                            fontSize: 14,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: widget.equbDetailModel.name,
                      color: Colors.white,
                    ),
                    TextWidget(
                      text:
                          'Created at ${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
                      color: Colors.white,
                      fontSize: 10,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Colors.white,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: '01',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      TextWidget(
                        text: 'Rounds',
                        color: Colors.white,
                        fontSize: 6,
                        weight: FontWeight.w200,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.images.svgs.adminIcon),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: "Admin",
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.groups_outlined,
                      color: Color(0xfF6D6D6D),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    TextWidget(
                      text:
                          'Members : ${widget.equbDetailModel.invitees.length}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.endTimeIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Start Date',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text:
                          '${widget.equbDetailModel.startDate.day.toString().padLeft(2, '0')}-${widget.equbDetailModel.startDate.month.toString().padLeft(2, '0')}-${widget.equbDetailModel.startDate.year}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.frequencyIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Frequency',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text: widget.equbDetailModel.frequency,
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.equbIcon,
                      color: const Color(0xfF6D6D6D),
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Contribution amount',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text: '\$${widget.equbDetailModel.contributionAmount}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.amountIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Total amount',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text:
                          '\$${(widget.equbDetailModel.numberOfMembers * widget.equbDetailModel.contributionAmount).toStringAsFixed(2)}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildMembers() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 25, bottom: 20),
          alignment: Alignment.centerLeft,
          child: TextWidget(
            text: 'All Members (${widget.equbDetailModel.invitees.length})',
          ),
        ),
        for (var member in widget.equbDetailModel.invitees)
          EqubMemberTile(
            equbInviteeModel: member,
            trailingWidget: const SizedBox.shrink(),
          ),
      ],
    );
  }
}
