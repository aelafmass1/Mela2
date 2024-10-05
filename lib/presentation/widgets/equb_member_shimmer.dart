import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';

class EqubMemberShimmer extends StatelessWidget {
  const EqubMemberShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomShimmer(
        width: 100.sw,
        height: 50,
      ),
    );
  }
}
