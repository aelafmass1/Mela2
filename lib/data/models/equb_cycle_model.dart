// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EqubCycleModel {
  final int cycleId;
  final int cycleNumber;
  final String? cycleDate;
  final Map? winner;
  EqubCycleModel({
    required this.cycleId,
    required this.cycleNumber,
    this.cycleDate,
    this.winner,
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

  factory EqubCycleModel.fromMap(Map map) {
    return EqubCycleModel(
      cycleId: map['cycleId'] as int,
      cycleNumber: map['cycleNumber'] as int,
      cycleDate: map['cycleDate'] != null ? map['cycleDate'] as String : null,
      winner: map['winner'] != null ? Map.from(map['winner']) : null,
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
        other.winner == winner;
  }

  @override
  int get hashCode {
    return cycleId.hashCode ^
        cycleNumber.hashCode ^
        cycleDate.hashCode ^
        winner.hashCode;
  }
}
