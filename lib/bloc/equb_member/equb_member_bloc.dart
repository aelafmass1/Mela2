import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';
import '../../data/models/contact_model.dart';
import '../../data/repository/equb_repository.dart';

part 'equb_member_event.dart';
part 'equb_member_state.dart';

class EqubMemberBloc extends Bloc<EqubMemberEvent, EqubMemberState> {
  EqubMemberBloc() : super(EqubMemberInitial()) {
    on<InviteEqubMemeber>(_onInviteEqubMember);
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

        final res = await EqubRepository(client: Client()).inviteMembers(
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
