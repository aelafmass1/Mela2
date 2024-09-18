// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'equb_bloc.dart';

class EqubState {
  final List<EqubDetailModel> equbList;

  EqubState({required this.equbList});

  EqubState copyWith({
    List<EqubDetailModel>? equbList,
  }) {
    return EqubState(
      equbList: equbList ?? this.equbList,
    );
  }
}

final class EqubLoading extends EqubState {
  EqubLoading({required super.equbList});
}

final class EqubSuccess extends EqubState {
  EqubSuccess({required super.equbList});
}

final class EqubFail extends EqubState {
  final String reason;
  EqubFail({required super.equbList, required this.reason});
}
