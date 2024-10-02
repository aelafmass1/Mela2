part of 'equb_member_bloc.dart';

sealed class EqubMemberState {}

final class EqubMemberInitial extends EqubMemberState {}

final class EqubMemberInviteLoading extends EqubMemberState {}

final class EqubMemberInviteFail extends EqubMemberState {
  final String reason;

  EqubMemberInviteFail({required this.reason});
}

final class EqubMemberInviteSuccess extends EqubMemberState {}

final class EqubWinnerLoading extends EqubMemberState {}

final class EqubWinnerFail extends EqubMemberState {
  final String reason;

  EqubWinnerFail({required this.reason});
}

final class EqubWinnerSuccess extends EqubMemberState {
  final int cycleNumber;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? role;

  EqubWinnerSuccess(
      {required this.cycleNumber,
      this.firstName,
      this.lastName,
      this.role,
      required this.phoneNumber});
}
