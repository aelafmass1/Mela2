import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart';

import '../../core/constants/url_constants.dart';

class ContactRepository {
  final Client client;

  ContactRepository({required this.client});

  Future<List> checkMyContacts({
    required String accessToken,
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
      Uri.parse('$baseUrl/contact/check'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        body,
      ),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data;
    }
    if (data.containsKey('errorResponse')) {
      return [
        {'error': data['errorResponse']['message']}
      ];
    }
    return [
      {
        'error': res.body,
      }
    ];
  }
}
