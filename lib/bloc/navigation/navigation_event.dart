part of 'navigation_bloc.dart';

sealed class NavigationEvent {}

final class NavigateTo extends NavigationEvent {
  final int index;
  final double? moneyAmount;
  final String? bankName;
  final double? bankRate;

  NavigateTo({
    required this.index,
    this.moneyAmount,
    this.bankName,
    this.bankRate,
  });
}
