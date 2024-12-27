import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';
import '../../data/models/contact_model.dart';
import '../../data/repository/equb_repository.dart';

part 'equb_member_event.dart';
part 'equb_member_state.dart';

class EqubMemberBloc extends Bloc<EqubMemberEvent, EqubMemberState> {
  final EqubRepository repository;
  EqubMemberBloc({required this.repository}) : super(EqubMemberInitial()) {
    on<InviteEqubMemeber>(_onInviteEqubMember);
    on<EqubAssignWinner>(_onEqubManualAssignWinner);
    on<EqubAutoPickWinner>(_onEqubAutoPickWinner);
  }

  /// Handles the logic for manually assigning a winner to an Equb cycle.
  ///
  /// This method is called when the `EqubAssignWinner` event is emitted. It first checks if the current state is not `EqubWinnerLoading`,
  /// and if so, it emits the `EqubWinnerLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to manually assign the specified member as the winner for the given Equb cycle ID. If the assignment is successful,
  /// it emits the `EqubWinnerSuccess` state with the details of the winner. If there is an error, it emits the `EqubWinnerFail`
  /// state with the error reason.
  _onEqubManualAssignWinner(EqubAssignWinner event, Emitter emit) async {
    try {
      if (state is! EqubManualWinnerLoading) {
        emit(EqubManualWinnerLoading());
        final token = await getToken();
        final res = await repository.manualAssignWinner(
          accessToken: token!,
          cycleId: event.cycleId,
          memberId: event.memberId,
        );
        if (res.containsKey('error')) {
          return emit(EqubManualWinnerFail(reason: res['error']));
        }
        emit(EqubManualWinnerSuccess(
          cycleNumber: res['cycleNumber'],
          firstName: res['winner']['user']['firstName'],
          lastName: res['winner']['user']['lastName'],
          phoneNumber: res.containsKey('phoneNumber') ? res['phoneNumber'] : '',
        ));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubManualWinnerFail(reason: error.toString()));
    }
  }

  /// Handles the logic for automatically picking a winner for an Equb cycle.
  ///
  /// This method is called when the `EqubAutoPickWinner` event is emitted. It first checks if the current state is not `EqubWinnerLoading`,
  /// and if so, it emits the `EqubWinnerLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to automatically pick a winner for the given Equb cycle ID. If the winner selection is successful,
  /// it emits the `EqubWinnerSuccess` state with the details of the winner. If there is an error, it emits the `EqubWinnerFail`
  /// state with the error reason.
  _onEqubAutoPickWinner(EqubAutoPickWinner event, Emitter emit) async {
    try {
      if (state is! EqubAutoWinnerLoading) {
        emit(EqubAutoWinnerLoading());
        final token = await getToken();
        final res = await repository.autoPickWinner(
          accessToken: token!,
          cycleId: event.cycleId,
        );
        if (res.containsKey('error')) {
          return emit(EqubAutoWinnerFail(reason: res['error']));
        }
        emit(EqubAutoWinnerSuccess(
          cycleNumber: res['cycleNumber'],
          firstName: res['winner']['user']['firstName'],
          lastName: res['winner']['user']['lastName'],
          phoneNumber: res.containsKey('phoneNumber') ? res['phoneNumber'] : '',
        ));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubAutoWinnerFail(reason: error.toString()));
    }
  }

  /// Handles the logic for inviting members to an Equb.
  ///
  /// This method is called when the `InviteEqubMemeber` event is emitted. It first checks if the current state is not `EqubMemberInviteLoading`,
  ///  and if so, it emits the `EqubMemberInviteLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  ///  to invite the specified members to the Equb with the given ID. If the invitation is successful, it emits the `EqubMemberInviteSuccess`
  ///  state. If there is an error, it emits the `EqubMemberInviteFail` state with the error reason.
  _onInviteEqubMember(InviteEqubMemeber event, Emitter emit) async {
    try {
      if (state is! EqubMemberInviteLoading) {
        emit(EqubMemberInviteLoading());

        final token = await getToken();

        final res = await repository.inviteMembers(
          accessToken: token!,
          equbId: event.equbId,
          members: event.contacts,
        );

        if (res.first.containsKey('error')) {
          return emit(EqubMemberInviteFail(reason: res.first['error']));
        }

        emit(EqubMemberInviteSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(EqubMemberInviteFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(EqubMemberInviteFail(reason: error.toString()));
    }
  }
}
