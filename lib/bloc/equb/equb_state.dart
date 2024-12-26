// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'equb_bloc.dart';

@immutable
class EqubState {
  final List<EqubDetailModel> equbList;

  const EqubState({required this.equbList});

  EqubState copyWith({
    List<EqubDetailModel>? equbList,
  }) {
    return EqubState(
      equbList: equbList ?? this.equbList,
    );
  }
}

final class EqubLoading extends EqubState {
  const EqubLoading({required super.equbList});
}

final class EqubSuccess extends EqubState {
  final List<EqubInviteeModel>? invitees;
  final EqubDetailModel? selectedEqub;
  final int? addedEqubId;
  const EqubSuccess({
    required super.equbList,
    this.invitees,
    this.selectedEqub,
    this.addedEqubId,
  });
}

final class EqubFail extends EqubState {
  final String reason;
  const EqubFail({required super.equbList, required this.reason});
}
