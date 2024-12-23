import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

Map<String, dynamic> getStatusDetails(String? status) {
  Color textColor;
  Widget bgImage;
  String normalizedText;
  debugPrint("status: $status");
  switch (status) {
    case "SUCCESS":
      textColor = ColorName.primaryColor;
      bgImage = Assets.images.receipt.image(fit: BoxFit.fill, height: 550);
      normalizedText = "Completed";
      break;
    case "PENDING":
      textColor = ColorName.yellow;
      bgImage =
          Assets.images.receiptPending.image(fit: BoxFit.fill, height: 540);
      normalizedText = "Pending";
      break;
    case "FAILED":
      textColor = ColorName.red;
      bgImage = Assets.images.receiptFailed.image(
        fit: BoxFit.fill,
        height: 550,
      );
      normalizedText = "Failed";
      break;
    default:
      textColor = ColorName.grey;
      bgImage = Assets.images.receipt
          .image(fit: BoxFit.fill, height: double.infinity);
      normalizedText = "_";
  }

  return {
    'textColor': textColor,
    'bgImage': bgImage,
    'normalizedText': normalizedText,
  };
}
