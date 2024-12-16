part of 'contact_bloc.dart';

/// Represents an event related to contacts.
sealed class ContactEvent {}

final class SearchContacts extends ContactEvent {
  final String query;
  SearchContacts({required this.query});
}

final class FetchContacts extends ContactEvent {}
