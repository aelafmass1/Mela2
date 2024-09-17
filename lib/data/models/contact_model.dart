// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ContactModel {
  final String name;
  final String phoneNumber;
  ContactModel({
    required this.name,
    required this.phoneNumber,
  });

  ContactModel copyWith({
    String? name,
    String? phoneNumber,
  }) {
    return ContactModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) =>
      ContactModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ContactModel(name: $name, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(covariant ContactModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => name.hashCode ^ phoneNumber.hashCode;
}
