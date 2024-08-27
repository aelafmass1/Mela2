part of 'payment_intent_bloc.dart';

sealed class PaymentIntentState {}

final class PaymentIntentInitial extends PaymentIntentState {}

final class PaymentIntentLoading extends PaymentIntentState {}

final class PaymentIntentFail extends PaymentIntentState {
  final String reason;

  PaymentIntentFail({required this.reason});
}

final class PaymentIntentSuccess extends PaymentIntentState {
  final String clientSecret;
  final String customerId;

  PaymentIntentSuccess({
    required this.clientSecret,
    required this.customerId,
  });
}
