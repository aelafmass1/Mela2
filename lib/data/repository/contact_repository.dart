import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:transaction_mobile_app/core/utils/process_error_response_.dart';

import '../../core/constants/url_constants.dart';

class ContactRepository {
  final InterceptedClient client;

  ContactRepository({required this.client});

  /// Checks the contacts on the device against a list of contacts on the server.
  ///
  /// This method takes a list of [Contact] objects and an access token, and sends
  /// the contact information to the server to check if the contacts exist on the
  /// server. The server response is then returned as a list of dynamic objects.
  ///
  /// Parameters:
  /// - `accessToken`: The access token to authenticate the request.
  /// - `contacts`: The list of [Contact] objects to check against the server.
  ///
  /// Returns:
  /// A list of dynamic objects containing the server response. If an error occurs,
  /// the list will contain an object with an 'error' key and the error message.
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
    return [processErrorResponse(data)];
  }

  Future<Map<String, dynamic>> searchContactsByTag({
    required String accessToken,
    required String query,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl/search/user?userTag=$query'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return data["response"];
    }
    return processErrorResponse(data);
  }
}
