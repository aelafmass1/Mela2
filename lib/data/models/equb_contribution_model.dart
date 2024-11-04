// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EqubContribution {
  final int memberId;
  final String memberName;
  final num contributionAmount;
  final bool paid;
  EqubContribution({
    required this.memberId,
    required this.memberName,
    required this.contributionAmount,
    required this.paid,
  });

  EqubContribution copyWith({
    int? memberId,
    String? memberName,
    num? contributionAmount,
    bool? paid,
  }) {
    return EqubContribution(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      paid: paid ?? this.paid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'memberId': memberId,
      'memberName': memberName,
      'contributionAmount': contributionAmount,
      'paid': paid,
    };
  }

  factory EqubContribution.fromMap(Map<String, dynamic> map) {
    return EqubContribution(
      memberId: map['memberId'] as int,
      memberName: map['memberName'] as String,
      contributionAmount: map['contributionAmount'] as num,
      paid: map['paid'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory EqubContribution.fromJson(String source) =>
      EqubContribution.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EqubContributions(memberId: $memberId, memberName: $memberName, contributionAmount: $contributionAmount, paid: $paid)';
  }

  @override
  bool operator ==(covariant EqubContribution other) {
    if (identical(this, other)) return true;

    return other.memberId == memberId &&
        other.memberName == memberName &&
        other.contributionAmount == contributionAmount &&
        other.paid == paid;
  }

  @override
  int get hashCode {
    return memberId.hashCode ^
        memberName.hashCode ^
        contributionAmount.hashCode ^
        paid.hashCode;
  }
}
