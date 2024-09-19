// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';

class EqubDetailModel {
  final int id;
  final String name;
  final int numberOfMembers;
  final double contributionAmount;
  final String frequency;
  final DateTime startDate;
  final List<EqubMemberModel> members;
  final List<EqubInviteeModel> invitees;
  EqubDetailModel({
    required this.id,
    required this.name,
    required this.numberOfMembers,
    required this.contributionAmount,
    required this.frequency,
    required this.startDate,
    required this.members,
    required this.invitees,
  });

  EqubDetailModel copyWith({
    int? id,
    String? name,
    int? numberOfMembers,
    double? contributionAmount,
    String? frequency,
    DateTime? startDate,
    List<EqubMemberModel>? members,
    List<EqubInviteeModel>? invitees,
  }) {
    return EqubDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      numberOfMembers: numberOfMembers ?? this.numberOfMembers,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      members: members ?? this.members,
      invitees: invitees ?? this.invitees,
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
      'members': members.map((x) => x.toMap()).toList(),
      'invitees': invitees.map((x) => x.toMap()).toList(),
    };
  }

  factory EqubDetailModel.fromMap(Map<String, dynamic> map) {
    return EqubDetailModel(
      id: map['id'] as int,
      name: map['name'] as String,
      numberOfMembers: map['numberOfMembers'] as int,
      contributionAmount: map['contributionAmount'] as double,
      frequency: map['frequency'] as String,
      startDate: DateTime.parse(map['startDate']),
      members: List<EqubMemberModel>.from(
        (map['members']).map<EqubMemberModel>(
          (x) => EqubMemberModel.fromMap(x),
        ),
      ),
      invitees: [],
      // invitees: List<EqubInviteeModel>.from(
      //   (map['invitees']).map<EqubInviteeModel>(
      //     (x) => EqubInviteeModel.fromMap(x),
      //   ),
      // ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubDetailModel.fromJson(String source) =>
      EqubDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubDetailModel(id: $id, name: $name, numberOfMembers: $numberOfMembers, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, members: $members, invitees: $invitees)';
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
        listEquals(other.members, members) &&
        listEquals(other.invitees, invitees);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        numberOfMembers.hashCode ^
        contributionAmount.hashCode ^
        frequency.hashCode ^
        startDate.hashCode ^
        members.hashCode ^
        invitees.hashCode;
  }
}
