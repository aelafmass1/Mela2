import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/custom_shimmer.dart';

class EqubCardShimmer extends StatelessWidget {
  const EqubCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      width: 100.sw,
      height: 100,
    );
  }
}
