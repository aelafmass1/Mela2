// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'navigation_bloc.dart';

class NavigationState {
  final TabController tabController;
  final int index;
  final double? moneyAmount;
  final String? bankName;
  final double? bankRate;

  NavigationState(
      {required this.tabController,
      required this.index,
      this.moneyAmount,
      this.bankName,
      this.bankRate});

  NavigationState copyWith({
    double? moneyAmount,
    String? bankName,
    double? bankRate,
    int? index,
  }) {
    return NavigationState(
      tabController: tabController,
      index: index ?? this.index,
      moneyAmount: moneyAmount ?? this.moneyAmount,
      bankName: bankName ?? this.bankName,
      bankRate: bankRate ?? this.bankRate,
    );
  }
}
