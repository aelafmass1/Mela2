import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/routing.dart';
import '../../data/models/receiver_info_model.dart';
import '../../gen/assets.gen.dart';
import 'text_widget.dart';

class TransactionTile extends StatelessWidget {
  final ReceiverInfo receiverInfo;
  const TransactionTile({super.key, required this.receiverInfo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
          color: const Color(0xFFA000C8).withOpacity(0.1),
        ),
        child: Center(
          child: SvgPicture.asset(
            Assets.images.svgs.transactionIcon,
            width: 24,
            height: 24,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: '\$${receiverInfo.amount}',
            fontSize: 14,
            weight: FontWeight.w600,
          ),
          TextWidget(
            text: DateFormat('hh:mm a').format(receiverInfo.transactionDate!),
            fontSize: 10,
            weight: FontWeight.w400,
          )
        ],
      ),
      title: TextWidget(
        text: receiverInfo.receiverName,
        fontSize: 14,
        weight: FontWeight.w400,
      ),
      subtitle: TextWidget(
        text: receiverInfo.receiverPhoneNumber,
        fontSize: 10,
        weight: FontWeight.w400,
      ),
    );
  }
}
