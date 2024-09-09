import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/payment_intent/payment_intent_bloc.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../bloc/money_transfer/money_transfer_bloc.dart';
import '../../core/utils/show_pincode.dart';
import '../../core/utils/show_snackbar.dart';
import '../../data/models/receiver_info_model.dart';
import '../../gen/assets.gen.dart';
import '../../gen/colors.gen.dart';

class StripePaymentPage extends StatelessWidget {
  final CardFormEditController controller;
  final ReceiverInfo receiverInfo;
  const StripePaymentPage(
      {super.key, required this.controller, required this.receiverInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                      ),
                    ),
                    SvgPicture.asset(
                      Assets.images.svgs.horizontalMelaLogo,
                      width: 130,
                    ),
                  ],
                ),
              ),
              CardFormField(
                controller: controller,
                style: CardFormStyle(
                  borderWidth: 0,
                  textColor: ColorName.primaryColor,
                  cursorColor: ColorName.primaryColor,
                  placeholderColor: Colors.black54,
                ),
              ),
              BlocConsumer<PaymentIntentBloc, PaymentIntentState>(
                listener: (context, paymentState) async {
                  if (paymentState is PaymentIntentFail) {
                    showSnackbar(context,
                        title: 'Error', description: paymentState.reason);
                  } else if (paymentState is PaymentIntentSuccess) {
                    try {
                      final clientSecret = paymentState.clientSecret;
                      final paymentIntent =
                          await Stripe.instance.confirmPayment(
                        paymentIntentClientSecret: clientSecret,
                        data: const PaymentMethodParams.card(
                          paymentMethodData: PaymentMethodData(),
                        ),
                      );
                      context.pop();
                      // Show a success message if the payment is successful
                      showSnackbar(
                        context,
                        title: 'Success',
                        description: 'Payment Successful!',
                      );

                      // Get the current user
                      final auth = FirebaseAuth.instance;
                      if (auth.currentUser != null) {
                        // Create a ReceiverInfo object with the recipient's information

                        // Add a SendMoney event to the MoneyTransferBloc to initiate the money transfer
                        context.read<MoneyTransferBloc>().add(
                              SendMoney(
                                receiverInfo: receiverInfo!,
                                paymentId: paymentIntent.id,
                              ),
                            );
                      }
                    } on StripeException catch (stripe) {
                      log(stripe.toString());
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: stripe.error.message ?? stripe.toString(),
                      );
                    } catch (error) {
                      log(error.toString());
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: error.toString(),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  return ButtonWidget(
                      child: state is PaymentIntentLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Continue',
                              color: Colors.white,
                              type: TextType.small,
                            ),
                      onPressed: () async {
                        if (await showPincode(context)) {
                          context.read<PaymentIntentBloc>().add(
                                FetchClientSecret(
                                  currency: 'USD',
                                  amount: receiverInfo.amount,
                                ),
                              );
                        }
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
