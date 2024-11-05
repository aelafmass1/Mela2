import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';

import '../../../../config/routing.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';

class HomeTransactionTile extends StatelessWidget {
  final ReceiverInfo receiverInfo;
  const HomeTransactionTile({super.key, required this.receiverInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        minVerticalPadding: 0,
        onTap: () {
          context.pushNamed(
            RouteName.receipt,
            extra: receiverInfo,
          );
        },
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: ColorName.primaryColor,
          ),
          child: Center(
            child: Assets.images.profileImage.image(),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextWidget(
              text: DateFormat('hh:mm a').format(receiverInfo.transactionDate!),
              fontSize: 10,
              weight: FontWeight.w400,
              color: ColorName.grey,
            ),
            const SizedBox(height: 5),
            TextWidget(
              text: '+\$${receiverInfo.amount}',
              fontSize: 16,
              weight: FontWeight.w700,
              color: ColorName.green,
            ),
          ],
        ),
        title: TextWidget(
          text: receiverInfo.receiverName,
          fontSize: 16,
          weight: FontWeight.w500,
        ),
        subtitle: TextWidget(
          text: receiverInfo.receiverPhoneNumber,
          fontSize: 10,
          weight: FontWeight.w400,
        ),
      ),
    );
  }
}
