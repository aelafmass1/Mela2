class CurrencyModel {
  final int? id;
  final String? code;
  final String? label;
  final String? backgroundColor;
  final String? textColor;

  CurrencyModel({
    this.id,
    this.code,
    this.label,
    this.backgroundColor,
    this.textColor,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'],
      code: json['code'],
      label: json['label'],
      backgroundColor: json['backgroundColor'],
      textColor: json['textColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'label': label,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
    };
  }
}

class TransferRateModel {
  final double? rate;
  final CurrencyModel? fromCurrency;
  final CurrencyModel? toCurrency;

  TransferRateModel({
    this.rate,
    this.fromCurrency,
    this.toCurrency,
  });

  factory TransferRateModel.fromJson(Map<String, dynamic> json) {
    return TransferRateModel(
      rate: json['rate']?.toDouble(),
      fromCurrency: json['fromCurrency'] != null
          ? CurrencyModel.fromJson(json['fromCurrency'])
          : null,
      toCurrency: json['toCurrency'] != null
          ? CurrencyModel.fromJson(json['toCurrency'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'fromCurrency': fromCurrency?.toJson(),
      'toCurrency': toCurrency?.toJson(),
    };
  }
}
