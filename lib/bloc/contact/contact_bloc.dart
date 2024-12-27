import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/repository/contact_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../data/models/wallet_model.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository repository;
  Map<String, List<WalletModel>?> contactWallets = {};
  ContactBloc({required this.repository}) : super(const ContactInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<SearchContacts>(_onSearchContacts);
  }

  _onFetchContacts(FetchContacts event, Emitter emit) async {
    try {
      emit(const ContactLoading());
      var contacts = await repository.fetchLocalContacts();
      final res = await repository.checkMyContacts(contacts: contacts);
      contactWallets.clear();
      for (var contactInfo in res) {
        if (contactInfo.containsKey('contactId')) {
          String contactId = contactInfo['contactId'];
                 if (contactInfo.containsKey('wallets')) {
            List<WalletModel> wallets = (contactInfo['wallets'] as List<dynamic>?)
                ?.map((x) => WalletModel.fromMap(x))
                .toList() ?? [];
            contactWallets[contactId] = wallets;
          } else {
            contactWallets[contactId] = null; 
          }
        }
      }
      List<ContactStatusModel> defaultContacts = contacts.map((contact) {
        List<WalletModel>? wallets = contactWallets[contact.id];
        return ContactStatusModel.fromFlutterContact(contact, wallets: wallets);
      }).toList();
      if (res.isEmpty) {
        return emit(ContactFilterSuccess(
          filteredContacts: defaultContacts,
          localContacs: contacts,
          remoteContacts: const [],
        ));
      }

      if (res.first.containsKey('error')) {
        return emit(ContactFail(message: res.first['error']));
      }

      final data = res.map((c) => c["contactId"] as String).toList();

      emit(ContactFilterSuccess(
        filteredContacts: defaultContacts,
        localContacs: contacts,
        remoteContacts: data,
      ));
    } on ServerException catch (error, stackTrace) {
      emit(ContactFail(message: error.message));
      await Sentry.captureException(error, stackTrace: stackTrace);
    } catch (error, stackTrace) {
      emit(ContactFail(message: error.toString()));
      await Sentry.captureException(error, stackTrace: stackTrace);
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
        if (res.isEmpty || res.first.containsKey('error')) {
          filteredContacts = [];
        } else {
          filteredContacts = res
              .map((contact) => ContactStatusModel.fromMap(contact))
              .toList();
        }
      } else {
        filteredContacts = state.localContacs
            .where((contact) {
              final name = contact.displayName.toLowerCase();
              final phoneNumber = contact.phones.isNotEmpty
                  ? contact.phones.first.number.toLowerCase().replaceAll(' ', '')
                  : null;

              if (phoneNumber == null) {
                return name.contains(query);
              }
              return name.contains(query) || phoneNumber.contains(query);
            })
            .map((contact) {
              List<WalletModel>? wallets = contactWallets[contact.id]; 
              return ContactStatusModel.fromFlutterContact(contact, wallets: wallets);
            })
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