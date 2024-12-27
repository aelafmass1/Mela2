part of 'payment_card_bloc.dart';

sealed class PaymentCardEvent {}

final class AddPaymentCard extends PaymentCardEvent {
  final String? token;
  AddPaymentCard({this.token});
}

final class FetchPaymentCards extends PaymentCardEvent {}

final class ResetPaymentCard extends PaymentCardEvent {}

final class AddBankAccount extends PaymentCardEvent {
  final String publicToken;
  AddBankAccount({required this.publicToken});
}
