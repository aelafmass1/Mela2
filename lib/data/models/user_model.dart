// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final int? id;
  final String? phoneNumber;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? countryCode;
  final String? verificationUUID;
  final String? pinCode;
  final String? toScreen;
  final String? otp;
  final bool? active;
  final DateTime? createdDate;

  UserModel({
    this.id,
    this.phoneNumber,
    this.password,
    this.firstName,
    this.lastName,
    this.email,
    this.countryCode,
    this.verificationUUID,
    this.pinCode,
    this.toScreen,
    this.otp,
    this.active,
    this.createdDate,
  });

  UserModel copyWith({
    int? id,
    String? phoneNumber,
    String? password,
    String? firstName,
    String? lastName,
    String? email,
    int? countryCode,
    String? verificationUUID,
    String? pinCode,
    String? toScreen,
    String? otp,
    bool? active,
    DateTime? createdDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      verificationUUID: verificationUUID ?? this.verificationUUID,
      pinCode: pinCode ?? this.pinCode,
      otp: otp ?? this.otp,
      toScreen: toScreen ?? this.toScreen,
      active: active ?? this.active,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': int.parse(phoneNumber ?? ''),
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'countryCode': countryCode,
      'verificationUUID': verificationUUID,
      'pinCode': pinCode,
      'active': active,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] != null ? map['id'] as int : null,
      phoneNumber: map['phoneNumber']?.toString(),
      password: map['password'] != null ? map['password'] as String : null,
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      countryCode:
          map['countryCode'] != null ? map['countryCode'] as int : null,
      verificationUUID: map['verificationUUID'] != null
          ? map['verificationUUID'] as String
          : null,
      pinCode: map['pinCode'] != null ? map['pinCode'] as String : null,
      active: map['active'] != null ? map['active'] as bool : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, password: $password, firstName: $firstName, lastName: $lastName, email: $email, countryCode: $countryCode, verificationUUID: $verificationUUID, pinCode: $pinCode, otp: $otp, active: $active, createdDate: $createdDate)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.countryCode == countryCode &&
        other.verificationUUID == verificationUUID &&
        other.pinCode == pinCode &&
        other.active == active &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        password.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        countryCode.hashCode ^
        verificationUUID.hashCode ^
        pinCode.hashCode ^
        active.hashCode ^
        createdDate.hashCode;
  }
}
