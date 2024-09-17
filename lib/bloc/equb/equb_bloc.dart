import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:transaction_mobile_app/data/repository/equb_repository.dart';

part 'equb_event.dart';
part 'equb_state.dart';

class EqubBloc extends Bloc<EqubEvent, EqubState> {
  EqubBloc()
      : super(EqubState(
          equbList: [],
        )) {
    on<AddEqub>(_onAddEqub);
  }

  _onAddEqub(AddEqub event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        List<EqubModel> equbs = state.equbList;

        final token = await getToken();
        final res = await EqubRepository.createEqub(
          event.equbModel,
          token!,
        );
        if (res.containsKey('error')) {
          return emit(EqubFail(equbList: state.equbList, reason: res['error']));
        }
        equbs.add(event.equbModel);
        int equbId = res['successResponse']['id'];

        final inviteRes = await EqubRepository.inviteMembers(
          accessToken: token,
          equbId: equbId,
          members: event.equbModel.members,
        );
        if (inviteRes.first.containsKey('error')) {
          return emit(EqubFail(
              equbList: state.equbList, reason: inviteRes.first['error']));
        }

        emit(EqubSuccess(
          equbList: equbs,
        ));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubFail(equbList: state.equbList, reason: error.toString()));
    }
  }
}
