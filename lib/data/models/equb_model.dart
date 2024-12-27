// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:transaction_mobile_app/data/models/contact_model.dart';

class EqubModel {
  final String name;
  final int numberOfMembers;
  final double contributionAmount;
  final String frequency;
  final DateTime startDate;
  final List<ContactModel> members;
  EqubModel({
    required this.name,
    required this.numberOfMembers,
    required this.contributionAmount,
    required this.frequency,
    required this.startDate,
    required this.members,
  });

  EqubModel copyWith({
    String? name,
    int? numberOfMembers,
    double? contributionAmount,
    String? frequency,
    DateTime? startingDate,
    List<ContactModel>? members,
  }) {
    return EqubModel(
      name: name ?? this.name,
      numberOfMembers: numberOfMembers ?? this.numberOfMembers,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      startDate: startingDate ?? startDate,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'numberOfMembers': numberOfMembers,
      'contributionAmount': contributionAmount,
      'frequency': frequency,
      'startDate': '${startDate.year}-${startDate.month}-${startDate.day}',
      // 'members': members.map((x) => x.toMap()).toList(),
    };
  }

  factory EqubModel.fromMap(Map<String, dynamic> map) {
    return EqubModel(
      name: map['name'] as String,
      numberOfMembers: map['numberOfMembers'] as int,
      contributionAmount: map['contributionAmount'] as double,
      frequency: map['frequency'] as String,
      startDate:
          DateTime.fromMillisecondsSinceEpoch(map['startingDate'] as int),
      members: List<ContactModel>.from(
        (map['members'] as List<int>).map<ContactModel>(
          (x) => ContactModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubModel.fromJson(String source) =>
      EqubModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubModel(name: $name, numberOfMembers: $numberOfMembers, contributionAmount: $contributionAmount, frequency: $frequency, startingDate: $startDate, members: $members)';
  }

  @override
  bool operator ==(covariant EqubModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.numberOfMembers == numberOfMembers &&
        other.contributionAmount == contributionAmount &&
        other.frequency == frequency &&
        other.startDate == startDate &&
        listEquals(other.members, members);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        numberOfMembers.hashCode ^
        contributionAmount.hashCode ^
        frequency.hashCode ^
        startDate.hashCode ^
        members.hashCode;
  }
}
