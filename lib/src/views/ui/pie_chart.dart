import 'dart:async';

import 'package:cm_pratical_assignment_2/src/model/Currency.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:core';
import 'dart:convert';
import 'package:async/async.dart';
import '../../model/Rates.dart';
import '../../model/RatesDto.dart';
import '../../services/SQLiteCurrencyStorage.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'app_bar.dart';


class PieChartWidget extends StatefulWidget {

  final String base;
  final List<String> symbols;
  final Map<String, double> money;
  //final AsyncMemoizer _memoizer= AsyncMemoizer();
  final currencySymbol;

  PieChartWidget(this.base, this.symbols, this.money, this.currencySymbol);

  @override
  _PieChartState createState() =>
    _PieChartState(base,  symbols, money, currencySymbol);
}




class _PieChartState extends State<PieChartWidget> {
  int touchedIndex = -1;

  Future<String> message = Future<String>.value('');

  String base;
  List<String> symbols;
  Map<String, double> money;

  double total=0;
  Map<String, double> moneyInBaseCurrency;
  bool isOriginal=true;
  var currencySymbol;
  //AsyncMemoizer _memoizer;

  List<Color> colors;
  Map rates;

  _PieChartState(String base,  List<String> symbols, Map<String, double> money, currencySymbol);


  @override
  void initState() {
    super.initState();
    //print(widget.base);
    base=widget.base;
    symbols=widget.symbols;
    money=widget.money;
    moneyInBaseCurrency = {...widget.money};
    currencySymbol=widget.currencySymbol;
    //_memoizer = AsyncMemoizer();

    message = getResponse(base, symbols);

    colors=createColors(money);

  }


  Future<String> getResponse(base, symbols) async {
    //await Future.delayed(Duration(seconds: 2));
    String symbolsString;

    //Because of the list space
    if(symbols[0]!=base)
      symbolsString=symbols[0];
    else
      symbolsString=symbols[1];

    for(int i=1; i<symbols.length; i++){
      if(symbols[i]!=base){
        symbolsString ='$symbolsString'+','+symbols[i];}
    }
    //print(symbolsString);
    final response = await http.get(Uri.http('data.fixer.io', '/api/latest',
        { 'access_key': '278379fff23019b5e4ceb3d7c73ca717',
          'base': base,
          'symbols': symbolsString}
    ));
    if (response.statusCode == 200)
      return getRates(response.body).toString();
    else {
      print('HTTP failed');
      return (await getRatesFromSQLite(base)).toString();
    }
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Column(
          children: [
            new GradientAppBar("wallet"),

            Padding(
              padding: EdgeInsets.only(top: 20.0)
              ),

            new Text("Total:",
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 17.0),
            ),
            FutureBuilder<String> (
                future: message,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if (snapshot.hasData){
                      var res=num.tryParse(snapshot.data)?.toDouble();
                      return Text((res).toStringAsFixed(3)+"$currencySymbol",//"Total: $total",
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 17.0),);
                    }
                    else if (snapshot.hasError)
                      if(money.length==1)
                        return Text(money.values.first.toStringAsFixed(3) + " " +money.keys.first);
                      return Text('Cannot convert to $base\n You can only convert to EUR');//${snapshot.error}
                    return CircularProgressIndicator();
                  }
                  return CircularProgressIndicator();
                }),
            Padding(
                padding: EdgeInsets.only(top: 15.0)
            ),
            new Text("Show in Original Currency",
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 13.0),
            ),
            Switch(
                value: isOriginal,
                onChanged: (value) {
                  setState(() {
                    isOriginal = value;
                  });
                },
                activeTrackColor: Colors.yellow,
                activeColor: Colors.orangeAccent,
              ),
            Expanded(
              child: PieChart(
                PieChartData(
                    pieTouchData:
                        PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        final desiredTouch =
                            pieTouchResponse.touchInput is! PointerExitEvent &&
                                pieTouchResponse.touchInput is! PointerUpEvent;
                        if (desiredTouch &&
                            pieTouchResponse.touchedSection != null) {
                          touchedIndex = pieTouchResponse
                              .touchedSection.touchedSectionIndex;
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    }),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 100,
                    sections: showingSections()
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back_rounded),
        onPressed: () => {Navigator.pop(context)},
      ),
    );
  }


  List<PieChartSectionData> showingSections() {
      final List<double> values=money.values.toList();
      List<double> valuesInBase=moneyInBaseCurrency.values.toList();
      final List<String> name=money.keys.toList();

      return List.generate(money.length, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 14.0;
        final radius = isTouched ? 60.0 : 50.0;

        return PieChartSectionData(
            color: colors[i],
            value: valuesInBase[i],
            title: isOriginal ? values[i].toStringAsFixed(2) +" " +name[i] : valuesInBase[i].toStringAsFixed(2) +" " +base,
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black)//const Color(0xffffffff))
        );
      });
  }

  double getRates(String data) {
    Map<String, dynamic> ratesMap = jsonDecode(data);

    var rat = Rate.fromJson(ratesMap);
    //print(' ${rat.rates}');
    rates = rat.rates;

    // insert into sqlite
    //   1) convert maps to string
    String ratesAsString = json.encode(rates);
    //   2) create object
    RatesDto ratesDto = new RatesDto(rat.base, ratesAsString);
    //   3) add to sqlite
    DBProvider.db.addRate(ratesDto);

    return getValuesInBaseCurrency();
  }

  Future<double> getRatesFromSQLite(String base) async {

    // try to get from sqlite
    RatesDto ratesDto = await DBProvider.db.getRates(base);

    if (ratesDto == null) {
      throw Exception('HTTP failed and rates not in local DB');
    }
    else {

      // convert string to maps
      Map<String, dynamic> ratesMap = jsonDecode(ratesDto.rates);

      rates = ratesMap;

      return getValuesInBaseCurrency();
    }
  }

  double getValuesInBaseCurrency() {
    /*print("Rates");
    print(rates);*/

    money.entries.forEach((quantity) {
      rates.entries.forEach((rate) {
        if(rate.key==quantity.key){
          moneyInBaseCurrency.update(rate.key, (value) => quantity.value/rate.value);
        }
      });
    });
    moneyInBaseCurrency.values.forEach((value) {
      total=total+value;
    });
    print("Total "+ total.toString());

    /*print("MoneyBaseCurrency ");
    print(moneyInBaseCurrency);
    print("Money ");
    print(money);*/

    return total;
  }


  List<Color> createColors(Map<String, double> money) {
    return List.generate(money.length, (i) => Color(Random().nextInt(0xffffffff))); //.withAlpha(0xff)
  }
}