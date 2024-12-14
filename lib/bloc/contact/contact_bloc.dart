import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/repository/contact_repository.dart';

import '../../core/exceptions/server_exception.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository repository;
  ContactBloc({required this.repository}) : super(const ContactInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<SearchContacts>(_onSearchContacts);
  }

  /// Handles the logic for checking the user's contacts and retrieving their contact status.
  ///
  /// This method is called when the [CheckMyContacts] event is dispatched. It first checks if the current state is not [ContactLoading], then emits the [ContactLoading] state. It then retrieves the access token, and uses the [ContactRepositoryImpl] to check the user's contacts. If the response is empty, it emits a [ContactSuccess] state with an empty list of contacts. If the response contains an error, it emits a [ContactFail] state with the error message. Otherwise, it maps the response to a list of [ContactStatusModel] and emits a [ContactSuccess] state with the list of contacts.
  ///
  /// If an error occurs during the process, it logs the error and emits a [ContactFail] state with the error message.
  _onFetchContacts(FetchContacts event, Emitter emit) async {
    try {
      emit(const ContactLoading());
      var contacts = await repository.fetchLocalContacts();
      final res = await repository.checkMyContacts(
        contacts: contacts,
      );
      var defaultContacts = contacts
          .map((contact) => ContactStatusModel.fromFlutterContact(contact))
          .toList();

      if (res.isEmpty) {
        return emit(ContactFilterSuccess(
            filteredContacts: defaultContacts,
            localContacs: contacts,
            remoteContacts: const []));
      }
      if (res.first.containsKey('error')) {
        return emit(ContactFail(message: res.first['error']));
      }

      final data = res.map((c) => c["contactId"] as String).toList();

      emit(ContactFilterSuccess(
          filteredContacts: defaultContacts,
          localContacs: contacts,
          remoteContacts: data));
    } on ServerException catch (error, stackTrace) {
      emit(ContactFail(message: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      emit(ContactFail(message: error.toString()));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
  }

  _onSearchContacts(SearchContacts event, Emitter emit) async {
    try {
      emit(ContactFilterLoading(
          localContacs: state.localContacs,
          remoteContacts: state.remoteContacts));

      List<ContactStatusModel> filteredContacts = [];

      final query = event.query.toLowerCase().replaceAll(' ', '');
      if (query.startsWith('@') && query.length > 3) {
        final res = await repository.searchContactsByTag(
          query: query.substring(1),
        );

        if (res.containsKey('error')) {
          filteredContacts = [];
        } else {
          filteredContacts = [ContactStatusModel.fromMap(res)];
        }
      } else {
        filteredContacts = state.localContacs
            .where((contact) {
              final name = contact.displayName.toLowerCase();
              final phoneNumber = contact.phones.isNotEmpty
                  ? contact.phones.first.number.toLowerCase()
                  : null;

              if (phoneNumber == null) {
                return name.contains(query);
              }
              return name.contains(query.toLowerCase()) ||
                  phoneNumber.replaceAll(" ", "").contains(query.toLowerCase());
            })
            .map((contact) => ContactStatusModel.fromFlutterContact(contact))
            .toList();
      }

      emit(
        ContactFilterSuccess(
            filteredContacts: filteredContacts,
            localContacs: state.localContacs,
            remoteContacts: state.remoteContacts),
      );
    } on ServerException catch (error, stackTrace) {
      emit(ContactFail(message: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      emit(ContactFail(message: error.toString()));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
  }
}
