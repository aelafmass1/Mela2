// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';

import '../../../../data/models/notification_model.dart';
import '../../../widgets/text_widget.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  String _calculateDurationTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'}';
    } else {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'}';
    }
  }

  String _getTokenValue(String t) {
    final token = t.replaceAll(RegExp('[{}\$.]'), '');
    final data =
        notification.data?.where((t) => token.contains(t.key)).toList();
    if (data?.isNotEmpty == true) {
      if (data != null) {
        if (token == 'amount') {
          return '\$${data.first.value}';
        }
        return data.first.value;
      }
    }

    return token;
  }

  Widget _parseTitle({
    required String title,
    required Color color,
  }) {
    final tokens = title.trim().split(' ');
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        children: [
          for (var token in tokens)
            if (token.contains('{') && token.contains('}'))
              TextSpan(
                text: "${_getTokenValue(token)} ",
                style: TextStyle(
                  color: color,
                ),
              )
            else
              TextSpan(
                text: "$token ",
              )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (notification.type) {
      case 'FAILED_TRANSFER':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.addMoneyFailIcon,
          trailing: SizedBox(
            width: 64,
            height: 25,
            child: _buildTileButton(
              color: ColorName.yellow,
              text: "Retry",
              onPressed: () {
                //
              },
            ),
          ),
          color: ColorName.yellow,
          textColor: ColorName.yellow,
          onTab: () {
            //
          },
        );
      case 'SECURITY_ISSUE':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.warningIcon,
          trailing: _buildTileButton(
            color: ColorName.red,
            text: "Confirm",
            onPressed: () {
              //
            },
          ),
          color: ColorName.red,
          onTab: () {
            //
          },
        );
      case 'SENT_MONEY':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.addMoneyFailIcon,
          showColorForBackground: false,
          color: ColorName.green,
          trailing: _buildTimeWidget(),
          onTab: () {
            //
          },
        );
      case 'EQUB':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.equbSavingIcon,
          showColorForBackground: false,
          color: ColorName.primaryColor,
          trailing: _buildTileButton(
            color: ColorName.primaryColor,
            text: "Pay Now",
            onPressed: () {
              //
            },
          ),
          onTab: () {
            //
          },
        );
      case 'REQUEST_MONEY':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.requestMoneyIcon,
          parsedTextColor: const Color(0xFFFF4D00),
          color: const Color(0xFFFF4D00),
          showColorForBackground: false,
          trailing: _buildTileButton(
            color: ColorName.primaryColor,
            text: "Confirm",
            onPressed: () {
              //
            },
          ),
          onTab: () {
            context.pushNamed(
              RouteName.moneyRequestDetail,
              extra: notification.referenceId,
            );
          },
        );
      case 'RECEIVED_MONEY':
        return _buildNotificationBaseTile(
          iconPath: Assets.images.svgs.addMoney,
          color: ColorName.green,
          trailing: _buildTimeWidget(),
          showColorForBackground: false,
          onTab: () {
            //
          },
        );
      default:
        return _buildNotificationBaseTile(
          color: const Color(0xFF8F00FF),
          parsedTextColor: const Color(0xFF8F00FF),
          showColorForBackground: false,
          iconPath: Assets.images.svgs.exchangeRateChangeIcon,
          onTab: () {
            //
          },
        );
    }
  }

  _buildTileButton({
    required String text,
    required Function() onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 64,
      height: 25,
      child: ButtonWidget(
        topPadding: 0,
        verticalPadding: 0,
        horizontalPadding: 0,
        borderRadius: BorderRadius.circular(5),
        color: color,
        onPressed: onPressed,
        child: TextWidget(
          text: text,
          color: ColorName.white,
          fontSize: 10,
        ),
      ),
    );
  }

  _buildNotificationBaseTile({
    required String iconPath,
    required Function() onTab,
    Color? color,
    Color? textColor,
    Color? parsedTextColor,
    Widget? trailing,
    bool showColorForBackground = true,
  }) {
    return ListTile(
      tileColor: showColorForBackground
          ? color?.withOpacity(0.05) ?? Colors.white
          : (notification.read == false)
              ? ColorName.primaryColor.withOpacity(0.05)
              : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      dense: true,
      minVerticalPadding: 0,
      horizontalTitleGap: 7,
      minLeadingWidth: 0,
      onTap: onTab,
      leading: CircleAvatar(
        backgroundColor: color?.withOpacity(0.1) ?? Colors.grey.shade200,
        radius: 22,
        child: SvgPicture.asset(
          height: 22,
          width: 22,
          iconPath,
          color: color ?? Colors.grey.shade700,
          fit: BoxFit.cover,
        ),
      ),
      title: _parseTitle(
        title: notification.title,
        color: parsedTextColor ?? ColorName.primaryColor,
      ),
      subtitle: TextWidget(
        text: notification.message,
        fontSize: 10,
        color: ColorName.grey,
        weight: FontWeight.w400,
      ),
      trailing: trailing,
    );
  }

  _buildTimeWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextWidget(
          text: _calculateDurationTime(notification.createdAt),
          fontSize: 10,
          color: ColorName.grey,
        ),
        Visibility(
          visible: notification.read == false,
          child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: ColorName.red, shape: BoxShape.circle)),
        )
      ],
    );
  }
}
