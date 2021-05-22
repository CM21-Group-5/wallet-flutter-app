import 'dart:collection';

import 'package:cm_pratical_assignment_2/src/views/ui/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';
import 'dart:core';

import 'app_bar.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*IR BUSCAR CURRENCIES DO USER A SQL Lite*/
  List<Locale> myCurrencies; //moedas
  List<Locale> supportedLocales; //minhas moedas
  List<int> _currencyAmounts; //valor de cada moeda

  String base;
  List<String> symbols;
  Map<String, double> money;

  //API_KEY = 278379fff23019b5e4ceb3d7c73ca717
  @override
  void initState() {
    super.initState();
    supportedLocales = [];
    _currencyAmounts = [];
    myCurrencies = [];

    symbols = [];
    money=new HashMap();

    myCurrencies = numberFormatSymbols.keys
        .where((key) => key.toString().contains('_'))
        .map((key) => key.toString().split('_'))
        .map((split) => Locale(split[0], split[1]))
        .toList();

    List<String> aux = [];
    List<Locale> auxList = [];
    for (var element in myCurrencies) {
      String code = numberFormatSymbols[element.toString()].DEF_CURRENCY_CODE;
      if (!aux.contains(code)) {
        aux.add(code);
        _currencyAmounts.add(0);
        auxList.add(element);
      }
    }
    myCurrencies = auxList;
  }

  void _incrementCurrencyValue(int currencyIndex, currencyCode) {
    if (_currencyAmounts[currencyIndex] >= 1000) return;
    setState(() {
      _currencyAmounts[currencyIndex]++;
      money.update(currencyCode, (value) => _currencyAmounts[currencyIndex].toDouble());
    });
  }

  void _decrementCurrencyValue(int currencyIndex, currencyCode) {
    if (_currencyAmounts[currencyIndex] <= 0) return;
    setState(() {
      _currencyAmounts[currencyIndex]--;
      money.update(currencyCode, (value) => _currencyAmounts[currencyIndex].toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new GradientAppBar("wallet"),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                // Let the ListView know how many items it needs to build.
                itemCount: supportedLocales.length,
                // Provide a builder function. This is where the magic happens.
                // Convert each item into a widget based on the type of item it is.
                itemBuilder: (context, index) {
                  final item = supportedLocales[index];
                  final currencyCode =
                      numberFormatSymbols[item.toString()].DEF_CURRENCY_CODE;
                  final flagPath = currencyCode.toLowerCase();
                  final currencySymbol =
                      NumberFormat.simpleCurrency(locale: item.toString())
                          .currencySymbol;
                  return ListTile(
                    leading: Image.asset('icons/currency/$flagPath.png',
                        package: 'currency_icons'),
                    subtitle: Text(
                      currencyCode,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0),
                    ),
                    title: Text(
                      _currencyAmounts[index].toString() + " " + currencySymbol,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 19.0),
                    ),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Material(
                            color: Color(0xFF3366FF), // button color
                            child: InkWell(
                              splashColor: Colors.white, // inkwell color
                              child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                              onTap: () => {_incrementCurrencyValue(index, currencyCode)},
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        ClipOval(
                          child: Material(
                            color: Color(0xFF00CCFF), // button color
                            child: InkWell(
                              splashColor: Colors.white, // inkwell color
                              child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  )),
                              onTap: () => {_decrementCurrencyValue(index, currencyCode)},
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onLongPress: () => {_remove(item, currencyCode)},
                    onTap: () {
                     // ***********************************************************************************
                      base=currencyCode;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PieChartWidget(base, symbols, money, currencySymbol)),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCurrency,
        icon: Icon(Icons.add),
        label: Text(
          'add currency',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addCurrency() {
    //print(_currencyAmounts);
    //print(supportedLocales);
    //print(NumberFormat.simpleCurrency(locale: item.toString()).currencySymbol);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(
            height: 450.0,
            width: 360.0,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  child: Center(
                    child: new Text(
                      "Add Currency",
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 26.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    // Let the ListView know how many items it needs to build.
                    itemCount: myCurrencies.length,
                    // Provide a builder function. This is where the magic happens.
                    // Convert each item into a widget based on the type of item it is.
                    itemBuilder: (context, index) {
                      final item = myCurrencies[index];
                      final currencyCode = numberFormatSymbols[item.toString()]
                          .DEF_CURRENCY_CODE;
                      final flagPath = currencyCode.toLowerCase();
                      return ListTile(
                        leading: Image.asset('icons/currency/$flagPath.png',
                            package: 'currency_icons'),
                        title: Text(
                          currencyCode,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0),
                        ),
                        subtitle: Text(
                          NumberFormat.simpleCurrency(locale: item.toString())
                              .currencySymbol,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0),
                        ),
                        trailing: ClipOval(
                          child: Material(
                            color: Color(0xFF3366FF), // button color
                            child: InkWell(
                              splashColor: Colors.white, // inkwell color
                              child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                              onTap: () {
                                _add(context, item, currencyCode);
                              }
                            ),
                          ),
                        ),
                        // Thi
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [const Color(0xFF3366FF), const Color(0xFF00CCFF)],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 0.5],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        );
      },
    );
  }

  void _add(context, locale, currencyCode) {
    setState(() {
      supportedLocales.add(locale);
      myCurrencies.remove(locale);
      symbols.add(currencyCode);
      money[currencyCode]= 0;
      //print(symbols);
    });
    Navigator.pop(context);
  }

  void _remove(locale, currencyCode) {
    setState(() {
      supportedLocales.remove(locale);
      myCurrencies.add(locale);
      symbols.add(currencyCode);
      money.remove(currencyCode);
      //print(symbols);
    });
  }
}
