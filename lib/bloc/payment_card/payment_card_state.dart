// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'payment_card_bloc.dart';

class PaymentCardState {
  final List<PaymentCardModel> paymentCards;

  PaymentCardState({required this.paymentCards});

  PaymentCardState copyWith({
    List<PaymentCardModel>? paymentCards,
  }) {
    return PaymentCardState(
      paymentCards: paymentCards ?? this.paymentCards,
    );
  }
}

final class PaymentCardInitial extends PaymentCardState {
  PaymentCardInitial({required super.paymentCards});
}

final class PaymentCardLoading extends PaymentCardState {
  PaymentCardLoading({required super.paymentCards});
}

final class PaymentCardFail extends PaymentCardState {
  final String reason;

  PaymentCardFail({required this.reason, required super.paymentCards});
}

final class PaymentCardSuccess extends PaymentCardState {
  final bool addedNewCard;
  PaymentCardSuccess({required super.paymentCards, this.addedNewCard = false});
}
