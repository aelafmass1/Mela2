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

final class EditEqub extends EqubMemberEvent {
  final EqubDetailModel equb;

  EditEqub({required this.equb});
}

final class SendReminder extends EqubMemberEvent {
  final int memberId;

  SendReminder({required this.memberId});
}

final class SendReminderToAll extends EqubMemberEvent {
  final int cycleId;

  SendReminderToAll({required this.cycleId});
}

final class FetchEqubJoinRequests extends EqubMemberEvent {
  final int equbId;

  FetchEqubJoinRequests({required this.equbId});
}

final class AcceptJoinRequest extends EqubMemberEvent {
  final int equbId;

  AcceptJoinRequest({required this.equbId});
}

final class ApproveJoinRequest extends EqubMemberEvent {
  final int requestId;

  ApproveJoinRequest({required this.requestId});
}

final class SetMemberAsPaid extends EqubMemberEvent {
  final int cycleId;
  final int memberId;

  SetMemberAsPaid({required this.cycleId, required this.memberId});
}

final class AssignAdmin extends EqubMemberEvent {
  final int equbId;
  final int memberId;

  AssignAdmin({required this.equbId, required this.memberId});
}
