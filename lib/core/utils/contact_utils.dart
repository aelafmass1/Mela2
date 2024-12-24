import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';

Future<bool> fetchContacts(BuildContext context, {bool isWeb = false}) async {
  try {
    if (isWeb) return true;

    final state = context.read<ContactBloc>().state;
    if (state is ContactInitial) {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        if (context.mounted) context.read<ContactBloc>().add(FetchContacts());
        return false;
      }
      return true;
    }
    return false;
  } catch (e) {
    return true;
  }
}
