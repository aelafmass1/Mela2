part of 'bank_fee_bloc.dart';

sealed class BankFeeState {}

final class BankFeeInitial extends BankFeeState {}

final class BankFeeLoading extends BankFeeState {}

final class BankFeeFail extends BankFeeState {
  final String reason;

  BankFeeFail({required this.reason});
}

final class BankFeeSuccess extends BankFeeState {
  final List<BankFeeModel> bankFees;

  BankFeeSuccess({required this.bankFees});
}
