// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ContactModel {
  final String contactId;
  final String name;
  final String phoneNumber;
  ContactModel({
    required this.contactId,
    required this.name,
    required this.phoneNumber,
  });

  ContactModel copyWith({
    String? contactId,
    String? name,
    String? phoneNumber,
  }) {
    return ContactModel(
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contactId': contactId,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      contactId: map['contactId'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) =>
      ContactModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ContactModel(contactId: $contactId, name: $name, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(covariant ContactModel other) {
    if (identical(this, other)) return true;

    return other.contactId == contactId &&
        other.name == name &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => contactId.hashCode ^ name.hashCode ^ phoneNumber.hashCode;
}
