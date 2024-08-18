// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'equb_bloc.dart';

class EqubState {
  final List<EqubModel> equbList;

  EqubState({required this.equbList});

  EqubState copyWith({
    List<EqubModel>? equbList,
  }) {
    return EqubState(
      equbList: equbList ?? this.equbList,
    );
  }
}
