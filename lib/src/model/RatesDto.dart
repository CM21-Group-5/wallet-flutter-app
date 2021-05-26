
class RatesDto {

  final String base;
  final String rates;

  RatesDto(this.base, this.rates);

  factory RatesDto.fromMap(Map<String, dynamic> json) => new RatesDto(
    json["base"],
    json["rates"],
  );

  Map<String, dynamic> toMap() => {
    "base": base,
    "rates": rates
  };

  @override
  String toString() {
    return 'RatesDto{base: $base, rates: $rates}';
  }
}