part of 'pincode_bloc.dart';

sealed class PincodeEvent {}

final class VerifyPincode extends PincodeEvent {
  final String pincode;

  VerifyPincode({required this.pincode});
}

final class SetPinCode extends PincodeEvent {
  final String pincode;

  SetPinCode({required this.pincode});
}
