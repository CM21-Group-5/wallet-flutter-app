import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:core';
import 'dart:convert';
import '../../model/Rates.dart';

import 'app_bar.dart';


class PieChartWidget extends StatefulWidget {

  final String base;
  final List<String> symbols;
  final Map<String, double> money;

  PieChartWidget(this.base, this.symbols, this.money);

  @override
  _PieChartState createState() =>
    _PieChartState(base,  symbols, money);

}



Future<String> getResponse(base, symbols) async {
  //print(base);
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
    return response.body;
  else
    throw Exception('HTTP failed');
}


class _PieChartState extends State<PieChartWidget> {
  int touchedIndex = -1;

  Future<String> message = Future<String>.value('');
  //String totalMessage=0;

  String base;
  List<String> symbols;
  Map<String, double> money;

  double total=0;
  Map<String, double> moneyInBaseCurrency;

  Map rates;

  _PieChartState(String base,  List<String> symbols, Map<String, double> money);


  @override
  void initState() {
    //print(widget.base);
    base=widget.base;
    symbols=widget.symbols;
    money=widget.money;
    moneyInBaseCurrency=widget.money;

    setState(() {
      message = getResponse(base, symbols);
      /*total = getValuesInBaseCurrency();*/
    });
  }



  //Criar uma caixa de texto com o valor total na moeda selecionada
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Column(
          children: [
            new GradientAppBar("wallet"),
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
                    sections: showingSections()),
              ),
            ),

            FutureBuilder<String> (
              future: message,
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  getRates(snapshot.data);
                  return Text(snapshot.data);
                }
                else if (snapshot.hasError)
                  return Text('${snapshot.error}');
                return CircularProgressIndicator();
              }),
            TextButton(
                onPressed: () {return Text(getValuesInBaseCurrency().toString());},
                child: Text('Press Me!'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back_rounded),
        onPressed: () => {Navigator.pop(context)},
      ),
    );
  }

  //Cria um chart com 4 partes e cada parte tem um valor default.
  //Isto tem de vir da lista da outra pagina
  List<PieChartSectionData> showingSections() {
    /*List<double> values=moneyInBaseCurrency.values.toList();
    List<String> name=moneyInBaseCurrency.keys.toList();*/
    return List.generate(moneyInBaseCurrency.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;


      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }

  void getRates(String data) {
    Map<String, dynamic> ratesMap = jsonDecode(data);

    var rat = Rate.fromJson(ratesMap);

    //print(' ${rat.rates}');
    rates=rat.rates;

    //getValuesInBaseCurrency();
  }

  double getValuesInBaseCurrency() {
    print(rates);
    print("Money ");
    print(money);


    money.entries.forEach((quantity) {
      rates.entries.forEach((rate) {
        if(rate.key==quantity.key){
          moneyInBaseCurrency.update(rate.key, (value) => quantity.value/rate.value);
        }
      });
    });
    print(moneyInBaseCurrency);

    moneyInBaseCurrency.values.forEach((value) {
      total=total+value;
    });
    print(total);

    return total;
  }
}