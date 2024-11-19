import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/data/models/payment_card_model.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../gen/colors.gen.dart';

class PaymentCardSelection extends StatefulWidget {
  final List<PaymentCardModel> paymentCards;
  final Function() onAddNewCardPressed;
  final ReceiverInfo? receiverInfo;
  final void Function(PaymentCardModel selectedCard)? onTab;
  const PaymentCardSelection({
    super.key,
    required this.paymentCards,
    required this.onAddNewCardPressed,
    this.receiverInfo,
    this.onTab,
  });

  @override
  State<PaymentCardSelection> createState() => _PaymentCardSelectionState();
}

class _PaymentCardSelectionState extends State<PaymentCardSelection> {
  int selectedPaymentMethodIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.sh,
      width: 100.sw,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: TextWidget(
                    text: 'Saved Payment Cards',
                    type: TextType.small,
                  ),
                ),
                Positioned(
                  left: 10,
                  child: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.paymentCards.length; i++)
                          _buildPaymentMethodTile(
                            id: i,
                            iconPath: widget.paymentCards[i].cardBrand == 'visa'
                                ? Assets.images.visaCard.path
                                : Assets.images.masteredCard.path,
                            title: widget.paymentCards[i].cardBrand ?? '---',
                            subTitle:
                                '${widget.paymentCards[i].cardBrand} ending **${widget.paymentCards[i].last4Digits}',
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.white,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () async {
                        context.pop();
                        widget.onAddNewCardPressed();
                      },
                      child: const TextWidget(
                        text: 'Add New Card',
                        type: TextType.small,
                      )),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ButtonWidget(
                onPressed: widget.receiverInfo == null && widget.onTab != null
                    ? () {
                        widget.onTab!(
                            widget.paymentCards[selectedPaymentMethodIndex]);
                      }
                    : () {
                        context.read<MoneyTransferBloc>().add(
                              SendMoney(
                                receiverInfo: widget.receiverInfo!,
                                paymentId: '',
                                savedPaymentId: widget
                                    .paymentCards[selectedPaymentMethodIndex]
                                    .id,
                              ),
                            );
                        context.pop();
                      },
                child: const TextWidget(
                  text: 'Next',
                  type: TextType.small,
                  color: Colors.white,
                )),
          )
        ],
      ),
    );
  }

  _buildPaymentMethodTile({
    required int id,
    required String iconPath,
    required String title,
    required String subTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: CardWidget(
          width: 100.sw,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            onTap: () {
              setState(() {
                selectedPaymentMethodIndex = id;
              });
              //
            },
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: AssetImage(iconPath), fit: BoxFit.cover),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            trailing: Checkbox(
              activeColor: ColorName.primaryColor,
              shape: const CircleBorder(),
              value: selectedPaymentMethodIndex == id,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethodIndex = id;
                });
              },
            ),
            title: TextWidget(
              text: title,
              fontSize: 15,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: subTitle,
                  fontSize: 11,
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 5),
              ],
            ),
          )),
    );
  }
}
