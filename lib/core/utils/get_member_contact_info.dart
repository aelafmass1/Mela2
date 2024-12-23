import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:transaction_mobile_app/data/models/equb_member_model.dart';

/// Retrieves a [ContactEqubMember] based on the provided phone number and list of contacts.
///
/// If the phone number is successfully parsed and the national number is extracted, this function
/// will search the provided list of contacts to find a matching phone number. If a match is found,
/// a [ContactEqubMember] is returned with the display name and phone number of the matching contact.
/// If no match is found, a [ContactEqubMember] is returned with the display name set to 'PENDING USER'
/// and the phone number set to '---'.
///
/// If the phone number cannot be parsed, this function will return a [ContactEqubMember] with the
/// display name set to 'PENDING USER' and the phone number set to '---'.
///
/// @param phoneNumber The phone number to search for.
/// @param contacts The list of contacts to search through.
/// @return A [Future] that completes with a [ContactEqubMember] containing the found user information.
Future<ContactEqubMember> getMemberContactInfo({
  required MelaUser equbUser,
  required List<Contact> contacts,
}) async {
  final phoneN = await removeCountryCode(
      '+${equbUser.countryCode}${equbUser.phoneNumber}');

  if (phoneN == null) {
    return ContactEqubMember(displayName: 'PENDING USER', phoneNumber: '---');
  }

  final user =
      contacts.where((c) => c.phones.first.number.endsWith(phoneN)).toList();
  if (user.isNotEmpty) {
    final phoneNumber = user.first.phones.first.number;
    final userName = user.first.displayName;
    return ContactEqubMember(displayName: userName, phoneNumber: phoneNumber);
  }
  if (equbUser.firstName != null && equbUser.lastName != null) {
    return ContactEqubMember(
        displayName: '${equbUser.firstName} ${equbUser.lastName}',
        phoneNumber: '+${equbUser.countryCode}${equbUser.phoneNumber}');
  }
  return ContactEqubMember(displayName: 'PENDING USER', phoneNumber: '---');
}

class ContactEqubMember {
  final String displayName;
  final String phoneNumber;

  ContactEqubMember({required this.displayName, required this.phoneNumber});
}

/// Removes the country code from the provided phone number.
///
/// This function takes a phone number as a string and attempts to parse it using the `PhoneNumber.parse()` method from the `phone_numbers_parser` package. If the parsing is successful, it extracts the national number (without the country code) and returns it. If the parsing fails, it returns `null`.
///
/// @param phoneNumber The phone number to remove the country code from.
/// @return The national number without the country code, or `null` if the parsing fails.
Future<String?> removeCountryCode(String phoneNumber) async {
  try {
    final parsedNumber = PhoneNumber.parse(phoneNumber);

    // Get the national number (without country code)
    String nationalNumber = parsedNumber.nsn;

    return nationalNumber;
  } catch (e) {
    return null;
  }
}
