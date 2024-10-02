import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/repository/contact_repository.dart';

import '../../core/exceptions/server_exception.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<CheckMyContacts>(_onCheckMyContacts);
  }

  /// Handles the logic for checking the user's contacts and retrieving their contact status.
  ///
  /// This method is called when the [CheckMyContacts] event is dispatched. It first checks if the current state is not [ContactLoading], then emits the [ContactLoading] state. It then retrieves the access token, and uses the [ContactRepository] to check the user's contacts. If the response is empty, it emits a [ContactSuccess] state with an empty list of contacts. If the response contains an error, it emits a [ContactFail] state with the error message. Otherwise, it maps the response to a list of [ContactStatusModel] and emits a [ContactSuccess] state with the list of contacts.
  ///
  /// If an error occurs during the process, it logs the error and emits a [ContactFail] state with the error message.
  _onCheckMyContacts(CheckMyContacts event, Emitter emit) async {
    try {
      if (state is! ContactLoading) {
        emit(ContactLoading());
        final token = await getToken();
        final res = await ContactRepository(client: Client()).checkMyContacts(
          accessToken: token!,
          contacts: event.contacts,
        );
        if (res.isEmpty) {
          return emit(ContactSuccess(
            contacts: [],
          ));
        }
        if (res.first.containsKey('error')) {
          return ContactFail(message: res.first['error']);
        }
        final data = res.map((c) => ContactStatusModel.fromMap(c)).toList();
        emit(
          ContactSuccess(
            contacts: data,
          ),
        );
      }
    } on ServerException catch (error, stackTrace) {
      emit(ContactFail(message: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(ContactFail(message: error.toString()));
    }
  }
}
