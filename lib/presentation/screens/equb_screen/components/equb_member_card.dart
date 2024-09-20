import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubMemberCard extends StatefulWidget {
  final int index;
  const EqubMemberCard({
    required this.index,
    super.key,
  });

  @override
  State<EqubMemberCard> createState() => _EqubMemberCardState();
}

class _EqubMemberCardState extends State<EqubMemberCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 50,
              height: 50,
              color: ColorName.primaryColor,
              alignment: Alignment.center,
              child: const TextWidget(
                text: "",
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Member Name",
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text: "+251912345678",
                  type: TextType.small,
                  fontSize: 14,
                  weight: FontWeight.w300,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          if (widget.index.isPrime())
            const Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: ColorName.yellow,
                ),
                SizedBox(
                  width: 5,
                ),
                TextWidget(
                  text: "Pending",
                  fontSize: 13,
                  color: ColorName.yellow,
                )
              ],
            ),
          if (!widget.index.isPrime() && widget.index.isOdd)
            const Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: ColorName.primaryColor,
                ),
                SizedBox(
                  width: 5,
                ),
                TextWidget(
                  text: "Joined",
                  fontSize: 13,
                  color: ColorName.primaryColor,
                )
              ],
            ),
          // if (!widget.index.isPrime() && widget.index.isEven) _buildInviteButton(context),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: ColorName.primaryColor,
          //     ),
          //     borderRadius: BorderRadius.circular(50),
          //   ),
          //   child: const TextWidget(
          //     text: "Invite",
          //     fontSize: 13,
          //     color: ColorName.primaryColor,
          //   ),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.more_vert_rounded),
          // ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: const BorderSide(
              width: 1,
              color: ColorName.primaryColor,
            ),
          ),
        ),
        onPressed: () async {
          final res =
              await Share.share('I Invite you to join our Mela Equb Group!', subject: 'Invitation to join Mela');
          log(res.status.toString());

          // if (res.status == ShareResultStatus.success) {
          //   if (onSuccessInvite != null) {
          //     onSuccessInvite!();
          //   }
          //   showDialog(
          //       // ignore: use_build_context_synchronously
          //       context: context,
          //       builder: ((_) => Dialog(
          //             child: Container(
          //               width: 100.sw,
          //               height: 55.sh,
          //               decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(
          //                   20,
          //                 ),
          //               ),
          //               child: Column(
          //                 children: [
          //                   const SizedBox(height: 40),
          //                   SvgPicture.asset(Assets.images.svgs.completeLogo),
          //                   const SizedBox(height: 20),
          //                   const TextWidget(
          //                     text: 'Invitation Sent',
          //                     color: ColorName.primaryColor,
          //                     fontSize: 24,
          //                   ),
          //                   const SizedBox(height: 20),
          //                   const TextWidget(
          //                     text: 'You have successfully sent your Invitation',
          //                     color: ColorName.grey,
          //                     textAlign: TextAlign.center,
          //                     fontSize: 14,
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           )));
          // }
        },
        child: const TextWidget(
          text: 'Invite',
          color: ColorName.primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
