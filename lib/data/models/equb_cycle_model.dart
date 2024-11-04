// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:transaction_mobile_app/data/models/equb_member_model.dart';

import 'equb_contribution_model.dart';

class EqubCycleModel {
  final int cycleId;
  final int cycleNumber;
  final String? cycleDate;
  final String status;
  final EqubMemberModel? winner;
  final List<EqubContribution>? contributions;
  EqubCycleModel({
    required this.cycleId,
    required this.cycleNumber,
    this.cycleDate,
    required this.status,
    this.winner,
    this.contributions,
  });

  EqubCycleModel copyWith({
    int? cycleId,
    int? cycleNumber,
    String? cycleDate,
    String? status,
    EqubMemberModel? winner,
    List<EqubContribution>? contributions,
  }) {
    return EqubCycleModel(
      cycleId: cycleId ?? this.cycleId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      cycleDate: cycleDate ?? this.cycleDate,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      contributions: contributions ?? this.contributions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cycleId': cycleId,
      'cycleNumber': cycleNumber,
      'cycleDate': cycleDate,
      'status': status,
      'winner': winner?.toMap(),
      'contributions': contributions?.map((e) => e.toMap()),
    };
  }

  factory EqubCycleModel.fromMap(Map<String, dynamic> map) {
    return EqubCycleModel(
      cycleId: map['cycleId'] as int,
      cycleNumber: map['cycleNumber'] as int,
      cycleDate: map['cycleDate'] != null ? map['cycleDate'] as String : null,
      status: map['status'] as String,
      winner: map['winner'] != null
          ? EqubMemberModel.fromMap(map['winner'] as Map<String, dynamic>)
          : null,
      contributions: map['contributions'] != null
          ? (map['contributions'] as List)
              .map((c) => EqubContribution.fromMap(c))
              .toList()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubCycleModel.fromJson(String source) =>
      EqubCycleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubCycleModel(cycleId: $cycleId, cycleNumber: $cycleNumber, cycleDate: $cycleDate, status: $status, winner: $winner, contributions: $contributions)';
  }

  @override
  bool operator ==(covariant EqubCycleModel other) {
    if (identical(this, other)) return true;

    return other.cycleId == cycleId &&
        other.cycleNumber == cycleNumber &&
        other.cycleDate == cycleDate &&
        other.status == status &&
        other.winner == winner;
  }

  @override
  int get hashCode {
    return cycleId.hashCode ^
        cycleNumber.hashCode ^
        cycleDate.hashCode ^
        status.hashCode ^
        winner.hashCode;
  }
}
