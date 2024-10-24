part of 'equb_bloc.dart';

sealed class EqubEvent {}

final class AddEqub extends EqubEvent {
  final EqubModel equbModel;
  final String currencyCode;

  AddEqub({required this.equbModel, required this.currencyCode});
}

final class FetchAllEqubs extends EqubEvent {}

final class FetchEqub extends EqubEvent {
  final int equbId;

  FetchEqub({required this.equbId});
}

final class FetchEqubMembers extends EqubEvent {
  final int equbId;

  FetchEqubMembers({required this.equbId});
}
