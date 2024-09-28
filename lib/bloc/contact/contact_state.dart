/// Represents the different states of the contact bloc.
///
/// [ContactInitial] is the initial state of the contact bloc.
/// [ContactLoading] is the state when the contact data is being loaded.
/// [ContactFail] is the state when there is an error loading the contact data.
/// [ContactSuccess] is the state when the contact data is successfully loaded.
part of 'contact_bloc.dart';

sealed class ContactState {}

final class ContactInitial extends ContactState {}

final class ContactLoading extends ContactState {}

final class ContactFail extends ContactState {
  final String message;

  ContactFail({required this.message});
}

final class ContactSuccess extends ContactState {
  final List<ContactStatusModel> contacts;

  ContactSuccess({required this.contacts});
}
