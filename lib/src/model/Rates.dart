import 'package:intl/intl.dart';

class Rate {
  bool success;
  int timestamp;
  String base;
  String date;
  Map rates;


  Rate(this.success, this.timestamp, this.base, this.date, this.rates);

  Rate.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        timestamp = json['timestamp'],
        base = json['base'],
        date = json['date'],
        rates = json['rates'];

  Map<String, dynamic> toJson() => {
    'success': success,
    'timestamp': timestamp,
    'base': base,
    'date': date,
    'rates': rates,
  };

  /*factory Rate.fromJson(dynamic json) {
    return Rate(json['success'] as bool, json['timestamp'] as DateTime, json['base'] as String,
        json['date'] as DateFormat, json['rates'] as Map<String, double>);
  }
*/
  @override
  String toString() {
    return 'Rate{success: $success, timestamp: $timestamp, base: $base, date: $date, rates: $rates}';
  }
}