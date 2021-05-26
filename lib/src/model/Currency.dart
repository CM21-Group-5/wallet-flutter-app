
class Currency {

  int id;

  final String languageCode;
  final String countryCode;
  final String currencySymbol;

  double amount;

  Currency(this.id, this.languageCode, this.countryCode, this.currencySymbol, this.amount);

  Currency.alternative01(this.languageCode, this.countryCode, this.currencySymbol, this.amount);


  factory Currency.fromMap(Map<String, dynamic> json) => new Currency(
    json["id"],
    json["languageCode"],
    json["countryCode"],
    json["currencySymbol"],
    json["amount"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "languageCode": languageCode,
    "countryCode": countryCode,
    "currencySymbol": currencySymbol,
    "amount": amount,
  };

  @override
  String toString() {
    return 'Currency{id: $id, '
        'languageCode: $languageCode, '
        'countryCode: $countryCode, '
        'currencySymbol: $currencySymbol, '
        'amount: $amount}';
  }
}