import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/image_builder.dart';

Map<String, dynamic> getStatusDetails(String? status) {
  Color textColor;
  Widget bgImage;
  String normalizedText;

  switch (status) {
    case "SUCCESS":
      textColor = ColorName.primaryColor;
      bgImage = ImageBuilder(
        image: Assets.images.receipt.path,
        height: 540,
        fit: BoxFit.fill,
      );
      normalizedText = "Completed";
      break;
    case "PENDING":
      textColor = ColorName.yellow;
      bgImage = ImageBuilder(
        image: Assets.images.receiptPending.path,
        height: 540,
        fit: BoxFit.fill,
      );
      normalizedText = "Pending";
      break;
    case "FAILED":
      textColor = ColorName.red;
      bgImage = ImageBuilder(
        image: Assets.images.receiptFailed.path,
        height: 540,
        fit: BoxFit.fill,
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
