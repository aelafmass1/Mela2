part of 'equb_member_bloc.dart';

sealed class EqubMemberEvent {}

final class InviteEqubMemeber extends EqubMemberEvent {
  final int equbId;
  final List<ContactModel> contacts;

  InviteEqubMemeber({required this.equbId, required this.contacts});
}

final class EqubAssignWinner extends EqubMemberEvent {
  final int cycleId;
  final int memberId;

  EqubAssignWinner({required this.cycleId, required this.memberId});
}

final class EqubAutoPickWinner extends EqubMemberEvent {
  final int cycleId;

  EqubAutoPickWinner({required this.cycleId});
}
