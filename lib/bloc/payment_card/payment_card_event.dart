part of 'payment_card_bloc.dart';

sealed class PaymentCardEvent {}

final class AddPaymentCard extends PaymentCardEvent {
  AddPaymentCard();
}

final class FetchPaymentCards extends PaymentCardEvent {}

final class ResetPaymentCard extends PaymentCardEvent {}

final class AddPaymentCardFromArray extends PaymentCardEvent {
  final PaymentCardModel card;

  AddPaymentCardFromArray({required this.card});
}
