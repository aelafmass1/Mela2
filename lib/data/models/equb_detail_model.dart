// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:transaction_mobile_app/data/models/equb_cycle_model.dart';
import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';

class EqubDetailModel {
  final int id;
  final String name;
  final int numberOfMembers;
  final double contributionAmount;
  final String frequency;
  final DateTime startDate;
  final String currency;
  final List<EqubMemberModel> members;
  final List<EqubInviteeModel> invitees;
  final List<EqubCycleModel> cycles;
  EqubDetailModel({
    required this.id,
    required this.name,
    required this.numberOfMembers,
    required this.contributionAmount,
    required this.frequency,
    required this.startDate,
    required this.currency,
    required this.members,
    required this.invitees,
    required this.cycles,
  });

  EqubDetailModel copyWith({
    int? id,
    String? name,
    int? numberOfMembers,
    double? contributionAmount,
    String? frequency,
    DateTime? startDate,
    String? currency,
    List<EqubMemberModel>? members,
    List<EqubInviteeModel>? invitees,
    List<EqubCycleModel>? cycles,
  }) {
    return EqubDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      numberOfMembers: numberOfMembers ?? this.numberOfMembers,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      currency: currency ?? this.currency,
      members: members ?? this.members,
      invitees: invitees ?? this.invitees,
      cycles: cycles ?? this.cycles,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'numberOfMembers': numberOfMembers,
      'contributionAmount': contributionAmount,
      'frequency': frequency,
      'startDate': startDate.millisecondsSinceEpoch,
      'currency': currency,
      'members': members.map((x) => x.toMap()).toList(),
      'invitees': invitees.map((x) => x.toMap()).toList(),
      'cycles': cycles.map((x) => x.toMap()).toList(),
    };
  }

  factory EqubDetailModel.fromMap(Map map) {
    return EqubDetailModel(
      id: map['id'] as int,
      name: map['name'] as String,
      numberOfMembers: map['numberOfMembers'] as int,
      contributionAmount: map['contributionAmount'] as double,
      frequency: map['frequency'] as String,
      startDate: DateTime.parse(map['startDate']),
      currency: map['currency'] as String,
      members: List<EqubMemberModel>.from(
        (map['members'] as List).map<EqubMemberModel>(
          (x) => EqubMemberModel.fromMap(x),
        ),
      ),
      invitees: [],
      cycles: map['cycles'] == null
          ? []
          : List<EqubCycleModel>.from(
              (map['cycles'] as List).map<EqubCycleModel>(
                (x) => EqubCycleModel.fromMap(x),
              ),
            ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubDetailModel.fromJson(String source) =>
      EqubDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubDetailModel(id: $id, name: $name, numberOfMembers: $numberOfMembers, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, currency: $currency, members: $members, invitees: $invitees, cycles: $cycles)';
  }

  @override
  bool operator ==(covariant EqubDetailModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.numberOfMembers == numberOfMembers &&
        other.contributionAmount == contributionAmount &&
        other.frequency == frequency &&
        other.startDate == startDate &&
        other.currency == currency &&
        listEquals(other.members, members) &&
        listEquals(other.invitees, invitees) &&
        listEquals(other.cycles, cycles);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        numberOfMembers.hashCode ^
        contributionAmount.hashCode ^
        frequency.hashCode ^
        startDate.hashCode ^
        currency.hashCode ^
        members.hashCode ^
        invitees.hashCode ^
        cycles.hashCode;
  }
}
