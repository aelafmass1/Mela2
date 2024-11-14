import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/check-details-bloc/check_details_bloc.dart';

class CheckDetailsSection extends StatelessWidget {
  const CheckDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckDetailsBloc, CheckDetailsState>(
      listener: (context, state) {
        if (state is CheckDetailsError) {
          showSnackbar(context, description: state.message);
        }
      },
      builder: (context, state) {
        if (state is CheckDetailsLoaded) {
          if (state.fees.isEmpty) {
            return const SizedBox.shrink();
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const TextWidget(
                  text: 'Check Details',
                  fontSize: 18,
                  weight: FontWeight.w600,
                ),
                if (state is CheckDetailsLoading)
                  const CircularProgressIndicator.adaptive(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorName.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  if (state is CheckDetailsLoaded) _buildFeeDetails(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        _buildFeeRow(
          label: 'Facilitation fee',
          amount: '\$20',
        ),
        const Divider(),
        const SizedBox(
          height: 5,
        ),
        _buildFeeRow(
          label: 'Connected bank account (ACH) fee',
          amount: '\$20',
        ),
        const SizedBox(
          height: 5,
        ),
        const Divider(),
        _buildFeeRow(
          label: 'Total',
          amount: '\$40',
          isTotal: true,
        ),
        // this is the last row
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildFeeRow({
    required String label,
    required String amount,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: label,
            color: isTotal ? null : ColorName.grey,
            fontSize: isTotal ? 16 : 14,
          ),
          Row(
            children: [
              TextWidget(
                text: amount,
                weight: FontWeight.w700,
                fontSize: 14,
              ),
              const SizedBox(
                width: 5,
              ),
              Icon(
                Icons.info_outline,
                color: ColorName.grey.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
