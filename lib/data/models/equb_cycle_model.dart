// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class EqubCycleModel {
  final int cycleId;
  final int cycleNumber;
  final String cycleDate;
  final Map winner;
  EqubCycleModel({
    required this.cycleId,
    required this.cycleNumber,
    required this.cycleDate,
    required this.winner,
  });

  EqubCycleModel copyWith({
    int? cycleId,
    int? cycleNumber,
    String? cycleDate,
    Map? winner,
  }) {
    return EqubCycleModel(
      cycleId: cycleId ?? this.cycleId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      cycleDate: cycleDate ?? this.cycleDate,
      winner: winner ?? this.winner,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cycleId': cycleId,
      'cycleNumber': cycleNumber,
      'cycleDate': cycleDate,
      'winner': winner,
    };
  }

  factory EqubCycleModel.fromMap(Map<String, dynamic> map) {
    return EqubCycleModel(
      cycleId: map['cycleId'] as int,
      cycleNumber: map['cycleNumber'] as int,
      cycleDate: map['cycleDate'] as String,
      winner: Map.from((map['winner'] as Map)),
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubCycleModel.fromJson(String source) =>
      EqubCycleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubCycleModel(cycleId: $cycleId, cycleNumber: $cycleNumber, cycleDate: $cycleDate, winner: $winner)';
  }

  @override
  bool operator ==(covariant EqubCycleModel other) {
    if (identical(this, other)) return true;

    return other.cycleId == cycleId &&
        other.cycleNumber == cycleNumber &&
        other.cycleDate == cycleDate &&
        mapEquals(other.winner, winner);
  }

  @override
  int get hashCode {
    return cycleId.hashCode ^
        cycleNumber.hashCode ^
        cycleDate.hashCode ^
        winner.hashCode;
  }
}
