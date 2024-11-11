part of 'payment_card_bloc.dart';

sealed class PaymentCardEvent {}

final class AddPaymentCard extends PaymentCardEvent {
  AddPaymentCard();
}

final class FetchPaymentCards extends PaymentCardEvent {}
