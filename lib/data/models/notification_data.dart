// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationData {
  final int id;
  final String key;
  final String value;
  NotificationData({
    required this.id,
    required this.key,
    required this.value,
  });

  NotificationData copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return NotificationData(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'key': key,
      'value': value,
    };
  }

  factory NotificationData.fromMap(Map map) {
    return NotificationData(
      id: map['id'] as int,
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationData.fromJson(String source) =>
      NotificationData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NotificationData(id: $id, key: $key, value: $value)';

  @override
  bool operator ==(covariant NotificationData other) {
    if (identical(this, other)) return true;

    return other.id == id && other.key == key && other.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode ^ value.hashCode;
}
