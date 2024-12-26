part of 'banks_bloc.dart';

@immutable
sealed class BanksState {}

final class BanksInitial extends BanksState {}

final class BanksLoading extends BanksState {}

final class BanksSuccess extends BanksState {
  final List<BankModel> bankList;

  BanksSuccess({required this.bankList});
}

final class BanksFail extends BanksState {
  final String reason;

  BanksFail({required this.reason});
}
