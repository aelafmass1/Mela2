part of 'pin_bloc.dart';

sealed class PinState {}

final class PinInitial extends PinState {}

final class PinLoading extends PinState {}

final class PinFail extends PinState {
  final String reason;

  PinFail({required this.reason});
}

final class PinSuccess extends PinState {}
