import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/equb_request_model.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/process_exception.dart';
import '../../core/utils/settings.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/equb_detail_model.dart';
import '../../data/repository/equb_repository.dart';

part 'equb_member_event.dart';
part 'equb_member_state.dart';

class EqubMemberBloc extends Bloc<EqubMemberEvent, EqubMemberState> {
  final EqubRepository repository;
  EqubMemberBloc({required this.repository}) : super(EqubMemberInitial()) {
    on<InviteEqubMemeber>(_onInviteEqubMember);
    on<EqubAssignWinner>(_onEqubManualAssignWinner);
    on<EqubAutoPickWinner>(_onEqubAutoPickWinner);
    on<EditEqub>(_onEqubEdit);
    on<SendReminder>(_onSendReminder);
    on<SendReminderToAll>(_onSendReminderToAll);
    on<FetchEqubJoinRequests>(_onFetchEqubJoinRequests);
    on<AcceptJoinRequest>(_onAcceptJoinRequest);
    on<ApproveJoinRequest>(_onApproveJoinRequest);
    on<SetMemberAsPaid>(_onSetMemberAsPaid);
    on<AssignAdmin>(_onAssignAdmin);
  }

  _onAssignAdmin(AssignAdmin event, Emitter emit) async {
    try {
      if (state is! AssignAdminLoading) {
        emit(AssignAdminLoading());
        final accessToken = await getToken();
        final res = await repository.assignAdmin(
          accessToken: accessToken ?? '',
          equbId: event.equbId,
          memberId: event.memberId,
        );
        if (res.containsKey('error')) {
          return emit(AssignAdminFail(reason: res['error']));
        }
        emit(AssignAdminSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(AssignAdminFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(AssignAdminFail(reason: processException(e)));
    }
  }

  _onSetMemberAsPaid(SetMemberAsPaid event, Emitter emit) async {
    try {
      if (state is! SetMemberAsPaidLoading) {
        emit(SetMemberAsPaidLoading());
        final accessToken = await getToken();
        final res = await repository.setMemberAsPaid(
          accessToken: accessToken ?? '',
          cycleId: event.cycleId,
          memberId: event.memberId,
        );
        if (res.containsKey('error')) {
          return emit(SetMemberAsPaidFail(reason: res['error']));
        }
        emit(SetMemberAsPaidSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(SetMemberAsPaidFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(SetMemberAsPaidFail(reason: processException(e)));
    }
  }

  /// Handles the logic for approving a join request to an Equb.
  ///
  /// This method is called when the `ApproveJoinRequest` event is emitted. It first checks if the current state is not `ApproveJoinRequestLoading`,
  /// and if so, it emits the `ApproveJoinRequestLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to approve the join request for the specified request ID. If the request is approved successfully, it emits the `ApproveJoinRequestSuccess` state.
  /// If there is an error, it emits the `ApproveJoinRequestFail` state with the error reason.
  _onApproveJoinRequest(ApproveJoinRequest event, Emitter emit) async {
    try {
      if (state is! ApproveJoinRequestLoading) {
        emit(ApproveJoinRequestLoading());
        final accessToken = await getToken();
        final res = await repository.approveJoinRequest(
          accessToken: accessToken ?? '',
          requestId: event.requestId,
        );
        if (res.containsKey('error')) {
          return emit(ApproveJoinRequestFail(reason: res['error']));
        }
        emit(ApproveJoinRequestSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(ApproveJoinRequestFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(ApproveJoinRequestFail(reason: processException(e)));
    }
  }

  /// Handles the logic for accepting a join request to an Equb.
  ///
  /// This method is called when the `AcceptJoinRequest` event is emitted. It first checks if the current state is not `SendEqubRequestLoading`,
  /// and if so, it emits the `SendEqubRequestLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to accept the join request for the specified Equb. If the request is accepted successfully, it emits the `SendEqubRequestSuccess` state.
  /// If there is an error, it emits the `SendEqubRequestFail` state with the error reason.
  _onAcceptJoinRequest(AcceptJoinRequest event, Emitter emit) async {
    try {
      if (state is! SendEqubRequestLoading) {
        emit(SendEqubRequestLoading());
        final accessToken = await getToken();
        final res = await repository.acceptJoinRequest(
          accessToken: accessToken ?? '',
          equbId: event.equbId,
        );
        if (res.containsKey('error')) {
          return emit(SendEqubRequestFail(reason: res['error']));
        }
        emit(SendEqubRequestSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(SendEqubRequestFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(SendEqubRequestFail(reason: processException(e)));
    }
  }

  /// Handles the logic for fetching Equb join requests.
  ///
  /// This method is called when the `FetchEqubJoinRequests` event is emitted. It first checks if the current state is not `FetchJoinRequestLoading`,
  /// and if so, it emits the `FetchJoinRequestLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to fetch the join requests for the specified Equb. If the requests are fetched successfully, it emits the `FetchJoinRequestSuccess` state
  /// with the list of join requests. If there is an error, it emits the `FetchJoinRequestFail` state with the error reason.
  _onFetchEqubJoinRequests(FetchEqubJoinRequests event, Emitter emit) async {
    try {
      if (state is! FetchJoinRequestLoading) {
        emit(FetchJoinRequestLoading());
        final accessToken = await getToken();
        final res = await repository.fetchJoinRequests(
          accessToken: accessToken ?? '',
          equbId: event.equbId,
        );
        final data = res['successResponse'] as List;
        if (res.containsKey('error')) {
          return emit(FetchJoinRequestFail(reason: res['error']));
        }
        emit(
          FetchJoinRequestSuccess(
            joinRequests: data.map((r) => EqubRequestModel.fromMap(r)).toList(),
          ),
        );
      }
    } on ServerException catch (error, stackTrace) {
      emit(FetchJoinRequestFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(FetchJoinRequestFail(reason: processException(e)));
    }
  }

  /// Handles the logic for sending a reminder to all Equb members.
  ///
  /// This method is called when the `SendReminderToAll` event is emitted. It first checks if the current state is not `EqubReminderToAllLoading`,
  /// and if so, it emits the `EqubReminderToAllLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to send a reminder to all Equb members. If the reminder is sent successfully, it emits the `EqubReminderToAllSuccess` state.
  /// If there is an error, it emits the `EqubReminderToAllFail` state with the error reason.
  _onSendReminderToAll(SendReminderToAll event, Emitter emit) async {
    try {
      if (state is! EqubReminderToAllLoading) {
        emit(EqubReminderToAllLoading());
        final accessToken = await getToken();
        final res = await repository.sendReminderToAll(
          accessToken: accessToken ?? '',
          cycleId: event.cycleId,
        );
        if (res.containsKey('error')) {
          return emit(EqubReminderToAllFail(reason: res['error']));
        }
        emit(EqubReminderToAllSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(EqubReminderToAllFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(EqubReminderToAllFail(reason: processException(e)));
    }
  }

  /// Handles the logic for sending a reminder to a specific Equb member.
  ///
  /// This method is called when the `SendReminder` event is emitted. It first checks if the current state is not `EqubReminderLoading`,
  /// and if so, it emits the `EqubReminderLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to send a reminder to the specified Equb member. If the reminder is sent successfully, it emits the `EqubReminderSuccess` state.
  /// If there is an error, it emits the `EqubReminderFail` state with the error reason.
  _onSendReminder(SendReminder event, Emitter emit) async {
    try {
      if (state is! EqubReminderLoading) {
        emit(EqubReminderLoading());
        final accessToken = await getToken();
        final res = await repository.sendReminder(
          accessToken: accessToken ?? '',
          memberId: event.memberId,
        );
        if (res.containsKey('error')) {
          return emit(EqubReminderFail(reason: res['error']));
        }
        emit(EqubReminderSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(EqubReminderFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(EqubReminderFail(reason: processException(e)));
    }
  }

  /// Handles the logic for editing an Equb.
  ///
  /// This method is called when the `EditEqub` event is emitted. It first checks if the current state is not `EqubEditLoading`,
  /// and if so, it emits the `EqubEditLoading` state. It then retrieves the access token, and uses the `EqubRepository`
  /// to edit the specified Equb. If the edit is successful, it emits the `EqubEditSuccess` state. If there is an error,
  /// it emits the `EqubEditFail` state with the error reason.
  _onEqubEdit(EditEqub event, Emitter emit) async {
    try {
      if (state is! EqubEditLoading) {
        emit(EqubEditLoading());
        final accessToken = await getToken();
        final res = await repository.editEqub(
            accessToken: accessToken ?? '', equb: event.equb);
        if (res.containsKey('error')) {
          return emit(EqubEditFail(reason: res['error']));
        }
        emit(EqubEditSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(EqubEditFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      emit(EqubEditFail(reason: processException(e)));
    }
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
      emit(EqubManualWinnerFail(reason: processException(error)));
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
    } on ServerException catch (error, stackTrace) {
      emit(EqubAutoWinnerFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(EqubAutoWinnerFail(reason: processException(error)));
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
      emit(EqubMemberInviteFail(reason: processException(error)));
    }
  }
}
