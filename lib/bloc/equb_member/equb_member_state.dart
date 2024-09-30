part of 'equb_member_bloc.dart';

sealed class EqubMemberState {}

final class EqubMemberInitial extends EqubMemberState {}

final class EqubMemberInviteLoading extends EqubMemberState {}

final class EqubMemberInviteFail extends EqubMemberState {
  final String reason;

  EqubMemberInviteFail({required this.reason});
}

final class EqubMemberInviteSuccess extends EqubMemberState {}
