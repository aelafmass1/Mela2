part of 'plaid_bloc.dart';

sealed class PlaidState {}

final class PlaidInitial extends PlaidState {}

final class PlaidLinkTokenLoading extends PlaidState {}

final class PlaidLinkTokenFail extends PlaidState {
  final String reason;

  PlaidLinkTokenFail({required this.reason});
}

final class PlaidLinkTokenSuccess extends PlaidState {
  final String linkToken;

  PlaidLinkTokenSuccess({required this.linkToken});
}

final class AddBankAccountLoading extends PlaidState {}

final class AddBankAccountFail extends PlaidState {
  final String reason;

  AddBankAccountFail({required this.reason});
}

final class AddBankAccountSuccess extends PlaidState {
  final PaymentCardModel card;
  AddBankAccountSuccess({required this.card});
}
