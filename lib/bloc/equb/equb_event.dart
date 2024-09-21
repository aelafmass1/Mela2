part of 'equb_bloc.dart';

sealed class EqubEvent {}

final class AddEqub extends EqubEvent {
  final EqubModel equbModel;

  AddEqub({required this.equbModel});
}

final class FetchAllEqubs extends EqubEvent {}

final class InviteMembers extends EqubEvent {
  final int equbId;
  final List<ContactModel> contacts;

  InviteMembers({required this.equbId, required this.contacts});
}

final class FetchEqub extends EqubEvent {
  final int equbId;

  FetchEqub({required this.equbId});
}
