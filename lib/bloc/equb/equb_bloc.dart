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
  /// Constructs an [EqubBloc] instance, which is a Bloc implementation for managing the state of Equb-related functionality.
  ///
  /// The [EqubBloc] initializes with an [EqubState] that has an empty [equbList]. It then registers event handlers for the following events:
  /// - [AddEqub]: Handles the addition of a new Equb.
  /// - [FetchAllEqubs]: Handles the fetching of all Equbs.
  /// - [InviteMembers]: Handles the invitation of members to an Equb.
  /// - [FetchEqub]: Handles the fetching of details for a specific Equb.
  /// - [FetchEqubMembers]: Handles the fetching of members for a specific Equb.
  EqubBloc()
      : super(EqubState(
          equbList: [],
        )) {
    on<AddEqub>(_onAddEqub);
    on<FetchAllEqubs>(_onFetchAllEqubs);
    on<InviteMembers>(_onInviteMembers);
    on<FetchEqub>(_onFetchEqub);
    on<FetchEqubMembers>(_onFetchEqubMembers);
  }

  /// Fetches the members of the Equb with the given [equbId].
  ///
  /// This method is called when the [FetchEqubMembers] event is dispatched.
  /// It first checks if the current state is not [EqubLoading], and if so, it emits the [EqubLoading] state with the current [equbList].
  /// It then retrieves the access token and uses the [EqubRepository] to fetch the members of the Equb with the given [equbId].
  /// If the fetch is successful, it emits the [EqubSuccess] state with the current [equbList].
  /// If an error occurs, it emits the [EqubFail] state with the current [equbList] and the error message.
  _onFetchEqubMembers(FetchEqubMembers event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        final token = await getToken();

        final res = await EqubRepository(client: Client()).fetchEqubMembers(
          accessToken: token!,
          equbId: event.equbId,
        );
        log(res.toString());
        emit(EqubSuccess(equbList: state.equbList));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubFail(equbList: state.equbList, reason: error.toString()));
    }
  }

  /// Fetches the details of the Equb with the given [equbId].
  ///
  /// This method is called when the [FetchEqub] event is dispatched.
  /// It first checks if the current state is not [EqubLoading], and if so, it emits the [EqubLoading] state with the current [equbList].
  /// It then retrieves the access token and uses the [EqubRepository] to fetch the details of the Equb with the given [equbId].
  /// If the fetch is successful, it emits the [EqubSuccess] state with the current [equbList] and the fetched [EqubDetailModel] in the [selectedEqub] field.
  /// If an error occurs, it emits the [EqubFail] state with the current [equbList] and the error message.
  /// After emitting the [EqubSuccess] state, it dispatches the [FetchEqubMembers] event to fetch the members of the Equb.
  _onFetchEqub(FetchEqub event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        final token = await getToken();

        final res = await EqubRepository(client: Client()).fetchEqubDetail(
          accessToken: token!,
          equbId: event.equbId,
        );
        if (res.containsKey('error')) {
          return emit(EqubFail(equbList: state.equbList, reason: res['error']));
        }
        final fetchedEqub = EqubDetailModel.fromMap(res);
        emit(
          EqubSuccess(
            equbList: state.equbList,
            selectedEqub: fetchedEqub,
          ),
        );
        add(FetchEqubMembers(equbId: event.equbId));
      }
    } catch (error) {
      log(error.toString());
      emit(EqubFail(equbList: state.equbList, reason: error.toString()));
    }
  }

  /// Invites members to the Equb with the given [equbId].
  ///
  /// This method is called when the [InviteMembers] event is dispatched.
  /// It first checks if the current state is not [EqubLoading], and if so, it emits the [EqubLoading] state with the current [equbList].
  /// It then retrieves the access token and uses the [EqubRepository] to invite the members specified in the [event.contacts] to the Equb with the given [event.equbId].
  /// If the invite is successful, it emits the [EqubSuccess] state with the current [equbList].
  /// If an error occurs, it emits the [EqubFail] state with the current [equbList] and the error message.
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

  /// Fetches all Equbs for the authenticated user.
  ///
  /// This method is called when the [FetchAllEqubs] event is dispatched.
  /// It first checks if the current state is not [EqubLoading], and if so, it emits the [EqubLoading] state with the current [equbList].
  /// It then retrieves the access token and uses the [EqubRepository] to fetch all Equbs for the authenticated user.
  /// If the fetch is successful, it emits the [EqubSuccess] state with the fetched Equbs.
  /// If the fetch is empty, it emits the [EqubSuccess] state with an empty [equbList].
  /// If an error occurs, it emits the [EqubFail] state with the current [equbList] and the error message.
  _onFetchAllEqubs(FetchAllEqubs event, Emitter emit) async {
    try {
      if (state is! EqubLoading) {
        emit(EqubLoading(equbList: state.equbList));
        final token = await getToken();

        final res = await EqubRepository(client: Client()).fetchEqubs(
          accessToken: token!,
        );
        if (res.isEmpty) {
          return emit(
            EqubSuccess(equbList: []),
          );
        }
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

  /// Handles the addition of a new Equb.
  ///
  /// This method is called when the [AddEqub] event is dispatched.
  /// It first checks if the current state is not [EqubLoading], and if so, it emits the [EqubLoading] state with the current [equbList].
  /// It then retrieves the access token and uses the [EqubRepository] to create a new Equb with the provided [EqubDetailModel].
  /// If the creation is successful, it invites the members specified in the [EqubDetailModel] using the [EqubRepository].
  /// If the creation or invitation is successful, it emits the [EqubSuccess] state with the updated [equbList] and the list of invited members.
  /// If an error occurs, it emits the [EqubFail] state with the current [equbList] and the error message.
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
