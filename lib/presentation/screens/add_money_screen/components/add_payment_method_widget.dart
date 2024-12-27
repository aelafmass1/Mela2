// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/get_strip_token.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/payment_card/payment_card_bloc.dart';

class AddPaymentMethodWidget extends StatefulWidget {
  const AddPaymentMethodWidget({super.key});

  @override
  State<AddPaymentMethodWidget> createState() => _AddPaymentMethodWidgetState();
}

class _AddPaymentMethodWidgetState extends State<AddPaymentMethodWidget> {
  final cardFormEditController = CardFormEditController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: 100.sw,
        padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.outlined(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(height: 20),
                    const TextWidget(
                      text: 'Accepted payment methods',
                      fontSize: 16,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    const TextWidget(
                      text: 'Add more payment methods for better access',
                      fontSize: 12,
                      weight: FontWeight.w400,
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAcceptedPaymentMethod(
                            Assets.images.masteredCard.path,
                          ),
                          _buildAcceptedPaymentMethod(
                            Assets.images.visaCard.path,
                          ),
                          _buildAcceptedPaymentMethod(
                            Assets.images.discoverLogo.path,
                          ),
                          _buildAcceptedPaymentMethod(
                            Assets.images.paypalLogo.path,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    CardFormField(
                      controller: cardFormEditController,
                      countryCode: "US",
                      style: CardFormStyle(
                        fontSize: 17,
                        textColor: Colors.white,
                        placeholderColor: Colors.white,
                        borderColor: Colors.white,
                        borderWidth: 1,
                        borderRadius: 10,
                        textErrorColor: ColorName.red,
                        cursorColor: Colors.white,
                        backgroundColor: ColorName.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<PaymentCardBloc, PaymentCardState>(
              listener: (context, state) {
                if (state is PaymentCardFail) {
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                } else if (state is PaymentCardSuccess) {
                  // context.read<PaymentCardBloc>().add(FetchPaymentCards());
                  context.pop();
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                  child: state is PaymentCardLoading
                      ? const LoadingWidget()
                      : const TextWidget(
                          text: 'Add your card',
                          type: TextType.small,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    if (cardFormEditController.details.complete) {
                      final token = await getStripeToken();
                      context.read<PaymentCardBloc>().add(
                            AddPaymentCard(token: token),
                          );
                    } else {
                      showSnackbar(
                        context,
                        description: 'Complete card information',
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  _buildAcceptedPaymentMethod(String path) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
      ),
    );
  }
}
