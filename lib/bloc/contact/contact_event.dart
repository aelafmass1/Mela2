part of 'contact_bloc.dart';

/// Represents an event related to contacts.
sealed class ContactEvent {}

final class CheckMyContacts extends ContactEvent {
  final List<Contact> contacts;

  CheckMyContacts({required this.contacts});
}
