import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../gen/colors.gen.dart';

void showSnackbar(
  BuildContext context, {
  required String title,
  required String description,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      closeIconColor: ColorName.primaryColor,
      content: Container(
        width: double.maxFinite,
        color: ColorName.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    width: 65.sw,
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 15,
                          ),
                    ),
                  )
                ]),
          ],
        ),
      ),
    ),
  );
}
