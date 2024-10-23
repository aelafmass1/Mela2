// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EqubCreatedByModel {
  final int id;
  final String firstName;
  final String lastName;
  EqubCreatedByModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  EqubCreatedByModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
  }) {
    return EqubCreatedByModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  factory EqubCreatedByModel.fromMap(Map<String, dynamic> map) {
    return EqubCreatedByModel(
      id: map['id'] as int,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubCreatedByModel.fromJson(String source) =>
      EqubCreatedByModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'EqubCreatedByModel(id: $id, firstName: $firstName, lastName: $lastName)';

  @override
  bool operator ==(covariant EqubCreatedByModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode => id.hashCode ^ firstName.hashCode ^ lastName.hashCode;
}
