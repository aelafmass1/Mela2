import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../widgets/custom_shimmer.dart';

class BankRateShimmer extends StatelessWidget {
  const BankRateShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CustomShimmer(
            width: 40,
            height: 34,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: CustomShimmer(width: 100.sw, height: 34),
          ),
          const SizedBox(width: 5),
          CustomShimmer(
            width: 60,
            height: 34,
            borderRadius: BorderRadius.circular(30),
          ),
        ],
      ),
    );
  }
}
