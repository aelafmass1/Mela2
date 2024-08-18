import 'package:flutter_contacts/flutter_contacts.dart';

class EqubModel {
  final String name;
  final double amount;
  final String frequency;
  final int numberOfMembers;
  final DateTime startingDate;
  final List<Contact> selectedContacts;

  EqubModel({
    required this.name,
    required this.amount,
    required this.frequency,
    required this.numberOfMembers,
    required this.startingDate,
    required this.selectedContacts,
  });
}
