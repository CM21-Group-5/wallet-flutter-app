
class Currency {

  int id;

  final String languageCode;
  final String countryCode;

  double amount;

  Currency(this.id, this.languageCode, this.countryCode, this.amount);

  Currency.alternative01(this.languageCode, this.countryCode, this.amount);

  Currency.alternative02(this.languageCode, this.countryCode);


  factory Currency.fromMap(Map<String, dynamic> json) => new Currency(
    json["id"],
    json["languageCode"],
    json["countryCode"],
    json["amount"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "languageCode": languageCode,
    "countryCode": countryCode,
    "amount": amount,
  };

  @override
  String toString() {
    return 'Currency{id: $id, languageCode: $languageCode, countryCode: $countryCode, amount: $amount}';
  }
}