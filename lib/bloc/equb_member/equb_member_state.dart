part of 'equb_member_bloc.dart';

sealed class EqubMemberState {}

final class EqubMemberInitial extends EqubMemberState {}

final class EqubMemberInviteLoading extends EqubMemberState {}

final class EqubMemberInviteFail extends EqubMemberState {
  final String reason;

  EqubMemberInviteFail({required this.reason});
}

final class EqubMemberInviteSuccess extends EqubMemberState {}

final class EqubManualWinnerLoading extends EqubMemberState {}

final class EqubManualWinnerFail extends EqubMemberState {
  final String reason;

  EqubManualWinnerFail({required this.reason});
}

final class EqubManualWinnerSuccess extends EqubMemberState {
  final int cycleNumber;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? role;

  EqubManualWinnerSuccess(
      {required this.cycleNumber,
      this.firstName,
      this.lastName,
      this.role,
      required this.phoneNumber});
}

final class EqubAutoWinnerLoading extends EqubMemberState {}

final class EqubAutoWinnerFail extends EqubMemberState {
  final String reason;

  EqubAutoWinnerFail({required this.reason});
}

final class EqubAutoWinnerSuccess extends EqubMemberState {
  final int cycleNumber;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? role;

  EqubAutoWinnerSuccess(
      {required this.cycleNumber,
      this.firstName,
      this.lastName,
      this.role,
      required this.phoneNumber});
}

final class EqubEditLoading extends EqubMemberState {}

final class EqubEditFail extends EqubMemberState {
  final String reason;

  EqubEditFail({required this.reason});
}

final class EqubEditSuccess extends EqubMemberState {}

final class EqubReminderLoading extends EqubMemberState {}

final class EqubReminderFail extends EqubMemberState {
  final String reason;

  EqubReminderFail({required this.reason});
}

final class EqubReminderSuccess extends EqubMemberState {}

final class EqubReminderToAllLoading extends EqubMemberState {}

final class EqubReminderToAllFail extends EqubMemberState {
  final String reason;

  EqubReminderToAllFail({required this.reason});
}

final class EqubReminderToAllSuccess extends EqubMemberState {}

final class FetchJoinRequestLoading extends EqubMemberState {}

final class FetchJoinRequestFail extends EqubMemberState {
  final String reason;

  FetchJoinRequestFail({required this.reason});
}

final class FetchJoinRequestSuccess extends EqubMemberState {
  final List<EqubRequestModel> joinRequests;

  FetchJoinRequestSuccess({required this.joinRequests});
}

final class SendEqubRequestLoading extends EqubMemberState {}

final class SendEqubRequestFail extends EqubMemberState {
  final String reason;

  SendEqubRequestFail({required this.reason});
}

final class SendEqubRequestSuccess extends EqubMemberState {}

final class ApproveJoinRequestLoading extends EqubMemberState {}

final class ApproveJoinRequestFail extends EqubMemberState {
  final String reason;

  ApproveJoinRequestFail({required this.reason});
}

final class ApproveJoinRequestSuccess extends EqubMemberState {}

final class SetMemberAsPaidLoading extends EqubMemberState {}

final class SetMemberAsPaidFail extends EqubMemberState {
  final String reason;

  SetMemberAsPaidFail({required this.reason});
}

final class SetMemberAsPaidSuccess extends EqubMemberState {}

final class AssignAdminLoading extends EqubMemberState {}

final class AssignAdminFail extends EqubMemberState {
  final String reason;

  AssignAdminFail({required this.reason});
}

final class AssignAdminSuccess extends EqubMemberState {}
