// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String? phoneNumber;
  final String? verificationId;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? birthDate;
  final String? email;
  UserModel({
    this.phoneNumber,
    this.verificationId,
    this.password,
    this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.email,
  });

  UserModel copyWith({
    String? phoneNumber,
    String? verificationId,
    String? password,
    String? firstName,
    String? lastName,
    String? gender,
    String? birthDate,
    String? email,
  }) {
    return UserModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phoneNumber': phoneNumber,
      // 'password': password,
      'firstName': firstName,
      'lastName': lastName,
      // 'gender': gender,
      // 'birthDate': birthDate,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      verificationId: map['verificationId'] != null
          ? map['verificationId'] as String
          : null,
      password: map['password'] != null ? map['password'] as String : null,
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      birthDate: map['birthDate'] != null ? map['birthDate'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(phoneNumber: $phoneNumber, verificationId: $verificationId, password: $password, firstName: $firstName, lastName: $lastName, gender: $gender, birthDate: $birthDate, email: $email)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.phoneNumber == phoneNumber &&
        other.verificationId == verificationId &&
        other.password == password &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.gender == gender &&
        other.birthDate == birthDate &&
        other.email == email;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode ^
        verificationId.hashCode ^
        password.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        gender.hashCode ^
        birthDate.hashCode ^
        email.hashCode;
  }
}
