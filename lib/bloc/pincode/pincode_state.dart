part of 'pincode_bloc.dart';

sealed class PincodeState {}

final class PinInitial extends PincodeState {}

final class PinLoading extends PincodeState {}

final class PinFail extends PincodeState {
  final String reason;

  PinFail({required this.reason});
}

final class PinSuccess extends PincodeState {}
