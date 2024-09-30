part of 'equb_member_bloc.dart';

sealed class EqubMemberEvent {}

final class InviteEqubMemeber extends EqubMemberEvent {
  final int equbId;
  final List<ContactModel> contacts;

  InviteEqubMemeber({required this.equbId, required this.contacts});
}
