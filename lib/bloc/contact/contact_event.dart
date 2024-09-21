part of 'contact_bloc.dart';

sealed class ContactEvent {}

final class CheckMyContacts extends ContactEvent {
  final List<Contact> contacts;

  CheckMyContacts({required this.contacts});
}
