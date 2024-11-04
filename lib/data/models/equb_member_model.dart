// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'equb_user_model.dart';

class EqubMemberModel {
  final int id;
  final int? userId;
  final String? username;
  final String role;
  final String status;
  final EqubUser? user;
  EqubMemberModel({
    required this.id,
    this.userId,
    this.username,
    required this.role,
    required this.status,
    this.user,
  });

  EqubMemberModel copyWith({
    int? id,
    int? userId,
    String? username,
    String? role,
    String? status,
    EqubUser? user,
  }) {
    return EqubMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'username': username,
      'role': role,
      'status': status,
      'user': user?.toMap(),
    };
  }

  factory EqubMemberModel.fromMap(Map<String, dynamic> map) {
    return EqubMemberModel(
      id: map['id'] as int,
      userId: map['userId'] != null ? map['userId'] as int : null,
      username: map['username'] != null ? map['username'] as String : null,
      role: map['role'] as String,
      status: map['status'] as String,
      user: map['user'] != null
          ? EqubUser.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubMemberModel.fromJson(String source) =>
      EqubMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubMemberModel(id: $id, userId: $userId, username: $username, role: $role, status: $status, user: $user)';
  }

  @override
  bool operator ==(covariant EqubMemberModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.role == role &&
        other.status == status &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        username.hashCode ^
        role.hashCode ^
        status.hashCode ^
        user.hashCode;
  }
}
