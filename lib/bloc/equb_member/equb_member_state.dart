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
