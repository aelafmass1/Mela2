import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/contact_status_model.dart';
import 'package:transaction_mobile_app/data/repository/contact_repository.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<CheckMyContacts>(_onCheckMyContacts);
  }
  _onCheckMyContacts(CheckMyContacts event, Emitter emit) async {
    try {
      if (state is! ContactLoading) ;
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
    } catch (error) {
      log(error.toString());
      emit(ContactFail(message: error.toString()));
    }
  }
}
