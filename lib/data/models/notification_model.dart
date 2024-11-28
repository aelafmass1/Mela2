// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:transaction_mobile_app/data/models/notification_data.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final int referenceId;
  final bool read;
  final bool active;
  final List<NotificationData>? data;
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.referenceId,
    required this.read,
    required this.active,
    this.data,
  });

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    int? referenceId,
    bool? read,
    bool? active,
    List<NotificationData>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      referenceId: referenceId ?? this.referenceId,
      read: read ?? this.read,
      active: active ?? this.active,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'referenceId': referenceId,
      'read': read,
      'active': active,
      'data': data?.map((x) => x.toMap()).toList(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      referenceId: map['referenceId'] as int,
      read: map['read'] as bool,
      active: map['active'] as bool,
      data: map['data'] != null
          ? List<NotificationData>.from(
              (map['data'] as List).map<NotificationData?>(
                (x) => NotificationData.fromMap(x),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, message: $message, type: $type, createdAt: $createdAt, referenceId: $referenceId, read: $read, active: $active, data: $data)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.referenceId == referenceId &&
        other.read == read &&
        other.active == active &&
        listEquals(other.data, data);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        message.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        referenceId.hashCode ^
        read.hashCode ^
        active.hashCode ^
        data.hashCode;
  }
}
