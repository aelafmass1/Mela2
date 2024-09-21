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
