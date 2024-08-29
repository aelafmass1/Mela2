part of 'pin_bloc.dart';

sealed class PinEvent {}

final class ValidatePin extends PinEvent {
  final String pincode;

  ValidatePin({required this.pincode});
}

final class SetPinCode extends PinEvent {}
