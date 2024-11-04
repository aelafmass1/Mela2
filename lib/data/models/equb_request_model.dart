// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'equb_user_model.dart';

class EqubRequestModel {
  final int id;
  final EqubUser user;
  final String status;
  final DateTime requestDate;
  EqubRequestModel({
    required this.id,
    required this.user,
    required this.status,
    required this.requestDate,
  });

  EqubRequestModel copyWith({
    int? id,
    EqubUser? user,
    String? status,
    DateTime? requestDate,
  }) {
    return EqubRequestModel(
      id: id ?? this.id,
      user: user ?? this.user,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
      'status': status,
      'requestDate': requestDate.millisecondsSinceEpoch,
    };
  }

  factory EqubRequestModel.fromMap(Map<String, dynamic> map) {
    return EqubRequestModel(
      id: map['id'] as int,
      user: EqubUser.fromMap(map['user']),
      status: map['status'] as String,
      requestDate: DateTime.parse(map['requestDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubRequestModel.fromJson(String source) =>
      EqubRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubRequestModel(id: $id, user: $user, status: $status, requestDate: $requestDate)';
  }

  @override
  bool operator ==(covariant EqubRequestModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.status == status &&
        other.requestDate == requestDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ user.hashCode ^ status.hashCode ^ requestDate.hashCode;
  }
}
