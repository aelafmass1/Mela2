/// Represents the different states of the contact bloc.
///
/// [ContactInitial] is the initial state of the contact bloc.
/// [ContactLoading] is the state when the contact data is being loaded.
/// [ContactFail] is the state when there is an error loading the contact data.
/// [ContactSuccess] is the state when the contact data is successfully loaded.
part of 'contact_bloc.dart';

sealed class ContactState extends Equatable {
  final List<String> remoteContacts;
  final List<Contact> localContacs;

  const ContactState(
      {this.remoteContacts = const [], this.localContacs = const []});

  @override
  List<Object> get props => [remoteContacts, localContacs];
}

final class ContactInitial extends ContactState {
  const ContactInitial({super.remoteContacts, super.localContacs});
}

final class ContactLoading extends ContactState {
  const ContactLoading({super.remoteContacts, super.localContacs});
}

final class ContactFail extends ContactState {
  final String message;

  const ContactFail(
      {required this.message, super.remoteContacts, super.localContacs});

  @override
  List<Object> get props => [message];
}

final class ContactFilterLoading extends ContactState {
  const ContactFilterLoading({super.remoteContacts, super.localContacs});
}

final class ContactFilterSuccess extends ContactState {
  final List<ContactStatusModel> filteredContacts;
  const ContactFilterSuccess(
      {required this.filteredContacts,
      super.remoteContacts,
      super.localContacs});
}

final class ContactFilterFailed extends ContactState {
  final String message;
  const ContactFilterFailed(
      {required this.message, super.remoteContacts, super.localContacs});
}
