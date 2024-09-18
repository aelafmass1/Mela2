import 'dart:convert';

class EqubMemberModel {
  final int userId;
  final String username;
  final String role;
  final String status;
  EqubMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.status,
  });

  EqubMemberModel copyWith({
    int? userId,
    String? username,
    String? role,
    String? status,
  }) {
    return EqubMemberModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'username': username,
      'role': role,
      'status': status,
    };
  }

  factory EqubMemberModel.fromMap(Map<String, dynamic> map) {
    return EqubMemberModel(
      userId: map['userId'] as int,
      username: map['username'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubMemberModel.fromJson(String source) =>
      EqubMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MemberModel(userId: $userId, username: $username, role: $role, status: $status)';
  }

  @override
  bool operator ==(covariant EqubMemberModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.username == username &&
        other.role == role &&
        other.status == status;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        username.hashCode ^
        role.hashCode ^
        status.hashCode;
  }
}
