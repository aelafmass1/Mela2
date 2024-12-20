import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

Map<String, dynamic> getStatusDetails(String? status) {
  Color textColor;
  Image bgImage;
  String normalizedText;
  debugPrint("status: $status");
  switch (status) {
    case "SUCCESS":
      textColor = ColorName.primaryColor;
      bgImage = Assets.images.receipt
          .image(fit: BoxFit.cover, height: double.infinity);
      normalizedText = "Completed";
      break;
    case "PENDING":
      textColor = ColorName.yellow;
      bgImage = Assets.images.receiptPending
          .image(fit: BoxFit.cover, height: double.infinity);

      normalizedText = "Pending";
      break;
    case "FAILED":
      textColor = ColorName.red;
      bgImage = Image.asset(
        "assets/images/receipt_failed.png",
        fit: BoxFit.cover,
        height: double.infinity,
      );
      normalizedText = "Failed";
      break;
    default:
      textColor = ColorName.grey;
      bgImage = Assets.images.receipt
          .image(fit: BoxFit.cover, height: double.infinity);
      normalizedText = "_";
  }

  return {
    'textColor': textColor,
    'bgImage': bgImage,
    'normalizedText': normalizedText,
  };
}
