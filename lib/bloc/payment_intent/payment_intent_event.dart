part of 'payment_intent_bloc.dart';

sealed class PaymentIntentEvent {}

final class FetchClientSecret extends PaymentIntentEvent {
  final String currency;
  final double amount;

  FetchClientSecret({required this.currency, required this.amount});
}
