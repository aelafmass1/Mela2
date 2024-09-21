import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/contact_model.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/data/repository/equb_repository.dart';

import '../../data/models/equb_detail_model.dart';

part 'equb_event.dart';
part 'equb_state.dart';

class EqubBloc extends Bloc<EqubEvent, EqubState> {
  EqubBloc()
      : super(EqubState(
          equbList: [],
        )) {
    on<AddEqub>(_onAddEqub);
    on<FetchEqubs>(_onFetchEqubs);
    on<InviteMembers>(_onInviteMembers);
  }
  _onInviteMembers(InviteMembers event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        List<EqubDetailModel> equbs = state.equbList;

        final token = await getToken();

        final res = await EqubRepository(client: Client()).inviteMembers(
          accessToken: token!,
          equbId: event.equbId,
          members: event.contacts,
        );

        if (res.first.containsKey('error')) {
          return emit(
              EqubFail(equbList: state.equbList, reason: res.first['error']));
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

  _onFetchEqubs(FetchEqubs event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        final token = await getToken();

        final res = await EqubRepository(client: Client()).fetchEqubs(
          accessToken: token!,
        );
        if (res.first.containsKey('error')) {
          return emit(
              EqubFail(equbList: state.equbList, reason: res.first['error']));
        }
        final fetchedEqubs =
            res.map((e) => EqubDetailModel.fromMap(e)).toList();
        emit(
          EqubSuccess(equbList: fetchedEqubs),
        );
      }
    } catch (error) {
      log(error.toString());
      emit(EqubFail(equbList: state.equbList, reason: error.toString()));
    }
  }

  _onAddEqub(AddEqub event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        List<EqubDetailModel> equbs = state.equbList;

        final token = await getToken();
        final res = await EqubRepository(client: Client()).createEqub(
          event.equbModel,
          token!,
        );
        if (res.containsKey('error')) {
          return emit(EqubFail(equbList: state.equbList, reason: res['error']));
        }
        int equbId = res['successResponse']['id'];

        final inviteRes = await EqubRepository(client: Client()).inviteMembers(
          accessToken: token,
          equbId: equbId,
          members: event.equbModel.members,
        );

        if (inviteRes.first.containsKey('error')) {
          return emit(EqubFail(
              equbList: state.equbList, reason: inviteRes.first['error']));
        }

        final invitees = inviteRes.map((m) {
          final invitee = m['invite'];
          final member = m['member'];
          return EqubInviteeModel(
            id: -1,
            phoneNumber: invitee != null ? invitee['phoneNumber'] : '',
            status: member != null ? member['status'] : '',
            name: invitee != null ? invitee['name'] : '',
          );
        }).toList();

        emit(EqubSuccess(
          equbList: equbs,
          invitees: invitees,
        ));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubFail(equbList: state.equbList, reason: error.toString()));
    }
  }
}
