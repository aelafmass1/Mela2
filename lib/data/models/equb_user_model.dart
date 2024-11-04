// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EqubUser {
  final String? firstName;
  final String? lastName;
  final int? phoneNumber;
  final int? countryCode;
  final bool? enabled;
  EqubUser({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.countryCode,
    this.enabled,
  });

  EqubUser copyWith({
    String? firstName,
    String? lastName,
    int? phoneNumber,
    int? countryCode,
    bool? enabled,
  }) {
    return EqubUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'enabled': enabled,
    };
  }

  factory EqubUser.fromMap(Map<String, dynamic> map) {
    return EqubUser(
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as int : null,
      countryCode:
          map['countryCode'] != null ? map['countryCode'] as int : null,
      enabled: map['enabled'] != null ? map['enabled'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubUser.fromJson(String source) =>
      EqubUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubUser(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, countryCode: $countryCode, enabled: $enabled)';
  }

  @override
  bool operator ==(covariant EqubUser other) {
    if (identical(this, other)) return true;

    return other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.countryCode == countryCode &&
        other.enabled == enabled;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        countryCode.hashCode ^
        enabled.hashCode;
  }
}
