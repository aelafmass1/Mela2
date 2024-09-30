import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../gen/colors.gen.dart';

class EqubMemberTile extends StatelessWidget {
  final EqubInviteeModel equbInviteeModel;
  final Widget? trailingWidget;
  final void Function()? onSuccessInvite;
  const EqubMemberTile({
    super.key,
    required this.equbInviteeModel,
    this.onSuccessInvite,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 50,
          height: 50,
          color: ColorName.primaryColor,
          alignment: Alignment.center,
          child: TextWidget(
            text: equbInviteeModel.name.isNotEmpty
                ? equbInviteeModel.name[0]
                : '',
            color: Colors.white,
          ),
        ),
      ),
      title: TextWidget(
        text: equbInviteeModel.name,
        fontSize: 16,
        weight: FontWeight.w400,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: equbInviteeModel.phoneNumber,
            type: TextType.small,
            fontSize: 14,
            weight: FontWeight.w300,
          ),
          if (equbInviteeModel.status.isEmpty)
            const TextWidget(
              text: "Not Invited",
              type: TextType.small,
              fontSize: 14,
              weight: FontWeight.w300,
              color: ColorName.red,
            ),
        ],
      ),
      trailing: trailingWidget ??
          (equbInviteeModel.status.isEmpty
              ? _buildInviteButton(context)
              : TextWidget(
                  text: equbInviteeModel.status == 'INVITED'
                      ? 'Pending'
                      : equbInviteeModel.status,
                  type: TextType.small,
                  fontSize: 14,
                  color: equbInviteeModel.status == 'Pending' ||
                          equbInviteeModel.status == 'INVITED'
                      ? Colors.orange
                      : null,
                  weight: FontWeight.w500,
                )),
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
          final res = await Share.share(
              'I Invite you to join our Mela Equb Group!',
              subject: 'Invitation to join Mela');
          log(res.status.toString());

          if (res.status == ShareResultStatus.success) {
            if (onSuccessInvite != null) {
              onSuccessInvite!();
            }
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
                            SvgPicture.asset(Assets.images.svgs.completeLogo),
                            const SizedBox(height: 20),
                            const TextWidget(
                              text: 'Invitation Sent',
                              color: ColorName.primaryColor,
                              fontSize: 24,
                            ),
                            const SizedBox(height: 20),
                            const TextWidget(
                              text:
                                  'You have successfully sent your Invitation',
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
        child: const TextWidget(
          text: 'Invite',
          color: ColorName.primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
