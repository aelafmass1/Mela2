import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

abstract class ContactRepository {
  Future<List> checkMyContacts({required List<Contact> contacts});
  Future<List<Map<String, dynamic>>> searchContactsByTag(
      {required String query});
  Future<List<Contact>> fetchLocalContacts();
  Future<List<Map<String, dynamic>>> searchByPhone({required String phone});
}

class ContactRepositoryImpl implements ContactRepository {
  final Dio client;

  ContactRepositoryImpl({required this.client});

  @override
  Future<List> checkMyContacts({
    required List<Contact> contacts,
  }) async {
    final body = [
      for (var contact in contacts)
        {
          "contactId": contact.id,
          "name": {
            "display": contact.displayName,
            "given": "",
            "middle": "",
            "family": "",
            "prefix": "",
            "suffix": "",
          },
          "organization": {
            "company": contact.organizations.isEmpty
                ? ""
                : contact.organizations.first.company,
            "jobTitle": '',
            "department": '',
          },
          "note": contact.notes.isEmpty ? "" : contact.notes.first,
          "phones": [
            {
              "type": "",
              "label":
                  contact.phones.isEmpty ? "" : contact.phones.first.label.name,
              "isPrimary": true,
              "number":
                  contact.phones.isEmpty ? "" : contact.phones.first.number,
            }
          ],
          "emails": [
            {
              "type": "",
              "label":
                  contact.emails.isEmpty ? "" : contact.emails.first.label.name,
              "isPrimary": true,
              "address":
                  contact.emails.isEmpty ? "" : contact.emails.first.address
            }
          ],
          "image": {"base64String": base64Encode(contact.photo ?? [])}
        }
    ];
    final res = await client.post(
      '/contact/check',
      data: body,
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    return [processErrorResponse(data)];
  }

  @override
  Future<List<Map<String, dynamic>>> searchContactsByTag({
    required String query,
  }) async {
    final res = await client.get(
      '/search/user?prefix=$query',
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (data["response"] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }
    return [processErrorResponse(data)];
  }

  @override
  Future<List<Contact>> fetchLocalContacts() async {
    return await FlutterContacts.getContacts(withProperties: true);
  }

  @override
  Future<List<Map<String, dynamic>>> searchByPhone(
      {required String phone}) async {
    final res = await client.get(
      '/search/phone?phoneNumber=$phone',
    );

    final data = res.data;
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (data["response"] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }
    return [processErrorResponse(data)];
  }
}
