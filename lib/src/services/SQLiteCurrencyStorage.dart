import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:cm_pratical_assignment_2/src/model/Currency.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "WalletDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Currency ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "languageCode TEXT,"
              "countryCode TEXT,"
              "amount REAL"
              ")");
        });
  }

  add(Currency currency) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Currency (languageCode,countryCode,amount)"
            " VALUES (?,?,?)",
        [currency.languageCode, currency.countryCode, currency.amount]);
    return raw;
  }

  update(Currency currency) async {
    final db = await database;
    var res = await db.update("Currency", currency.toMap(),
        where: "id = ?", whereArgs: [currency.id]);
    return res;
  }

  updateCurrency(Currency currency) async {
    final db = await database;
    var res = await db.update("Currency", currency.toMap(),
        where: "languageCode = ? AND countryCode = ?",
        whereArgs: [currency.languageCode, currency.countryCode]);
    return res;
  }

  get(int id) async {
    final db = await database;
    var res = await db.query("Currency", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Currency.fromMap(res.first) : null;
  }

  Future<List<Currency>> getCurrencies() async {
    final db = await database;
    var res = await db.query("Currency");
    List<Currency> list =
    res.isNotEmpty ? res.map((c) => Currency.fromMap(c)).toList() : [];
    return list;
  }

  delete(int id) async {
    final db = await database;
    return db.delete("Currency", where: "id = ?", whereArgs: [id]);
  }

  deleteCurrency(Currency currency) async {
    final db = await database;
    return db.delete("Currency",
        where: "languageCode = ? AND countryCode = ?",
        whereArgs: [currency.languageCode, currency.countryCode]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Currency");
  }
}