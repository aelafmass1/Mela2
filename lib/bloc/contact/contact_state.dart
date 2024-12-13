/// Represents the different states of the contact bloc.
///
/// [ContactInitial] is the initial state of the contact bloc.
/// [ContactLoading] is the state when the contact data is being loaded.
/// [ContactFail] is the state when there is an error loading the contact data.
/// [ContactSuccess] is the state when the contact data is successfully loaded.
part of 'contact_bloc.dart';

sealed class ContactState {
  final List<String> remoteContacts;
  final List<Contact> localContacs;

  ContactState({this.remoteContacts = const [], this.localContacs = const []});
}

final class ContactInitial extends ContactState {
  ContactInitial({super.remoteContacts, super.localContacs});
}

final class ContactLoading extends ContactState {
  ContactLoading({super.remoteContacts, super.localContacs});
}

final class ContactFail extends ContactState {
  final String message;

  ContactFail(
      {required this.message, super.remoteContacts, super.localContacs});
}

final class ContactSuccess extends ContactState {
  ContactSuccess({required super.remoteContacts, super.localContacs});
}

final class ContactFilterLoading extends ContactState {
  ContactFilterLoading({super.remoteContacts, super.localContacs});
}

final class ContactFilterSuccess extends ContactState {
  final List<ContactStatusModel> filteredContacts;
  ContactFilterSuccess(
      {required this.filteredContacts,
      super.remoteContacts,
      super.localContacs});
}

final class ContactFilterFailed extends ContactState {
  final String message;
  ContactFilterFailed(
      {required this.message, super.remoteContacts, super.localContacs});
}
