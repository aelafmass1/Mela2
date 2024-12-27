part of 'plaid_bloc.dart';

sealed class PlaidEvent {}

final class CreateLinkToken extends PlaidEvent {}

final class AddBankAccount extends PlaidEvent {
  final String publicToken;

  AddBankAccount({required this.publicToken});
}
