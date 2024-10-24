import 'dart:convert';

class EqubInviteeModel {
  final int id;
  final String phoneNumber;
  final String status;
  final String name;
  EqubInviteeModel({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.name,
  });

  EqubInviteeModel copyWith({
    int? id,
    String? phoneNumber,
    String? status,
    String? name,
  }) {
    return EqubInviteeModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'status': status,
      'name': name,
    };
  }

  factory EqubInviteeModel.fromMap(Map<String, dynamic> map) {
    return EqubInviteeModel(
      id: map['id'] as int,
      phoneNumber: map['phoneNumber'] as String,
      status: map['status'] as String,
      name: (map['name'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubInviteeModel.fromJson(String source) =>
      EqubInviteeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InviteeModel(id: $id, phoneNumber: $phoneNumber, status: $status, name: $name)';
  }

  @override
  bool operator ==(covariant EqubInviteeModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.status == status &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ phoneNumber.hashCode ^ status.hashCode ^ name.hashCode;
  }
}
