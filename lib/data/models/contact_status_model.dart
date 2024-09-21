// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ContactStatusModel {
  final String contactId;
  final String contactStatus;
  final int userId;
  ContactStatusModel({
    required this.contactId,
    required this.contactStatus,
    required this.userId,
  });

  ContactStatusModel copyWith({
    String? contactId,
    String? contactStatus,
    int? userId,
  }) {
    return ContactStatusModel(
      contactId: contactId ?? this.contactId,
      contactStatus: contactStatus ?? this.contactStatus,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contactId': contactId,
      'contactStatus': contactStatus,
      'userId': userId,
    };
  }

  factory ContactStatusModel.fromMap(Map<String, dynamic> map) {
    return ContactStatusModel(
      contactId: map['contactId'] as String,
      contactStatus: map['contactStatus'] as String,
      userId: map['userId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactStatusModel.fromJson(String source) =>
      ContactStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ContactStatusModel(contactId: $contactId, contactStatus: $contactStatus, userId: $userId)';

  @override
  bool operator ==(covariant ContactStatusModel other) {
    if (identical(this, other)) return true;

    return other.contactId == contactId &&
        other.contactStatus == contactStatus &&
        other.userId == userId;
  }

  @override
  int get hashCode =>
      contactId.hashCode ^ contactStatus.hashCode ^ userId.hashCode;
}
