class TransferFeesModel {
  final int? id;
  final String? label;
  final String? type;
  final num? amount;
  final String? paymentMethod;

  TransferFeesModel({
    this.id,
    this.label,
    this.type,
    this.amount,
    this.paymentMethod,
  });

  factory TransferFeesModel.fromJson(Map json) {
    return TransferFeesModel(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
  }
}
