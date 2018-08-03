import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:apod_viewer/model/apod_model.dart';

class FavoriteDatabase {
  static final FavoriteDatabase _instance = FavoriteDatabase._internal();

  factory FavoriteDatabase() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  FavoriteDatabase._internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE Favorite (
        date TEXT PRIMARY KEY,
        title TEXT,
        copyright TEXT,
        explanation TEXT,
        url TEXT,
        hdurl TEXT,
        media_type TEXT,
        service_version TEXT,
        is_favorite BIT)''');
    // TODO: remove debug text
    // print('Database Was Created');
  }

  Future<int> addFavorite(Apod apod) async {
    var dbClient = await db;
    int res;
    List<Map> exist = await dbClient
        .query("Favorite", where: "date = ?", whereArgs: [apod.date]);
    if (exist.length == 0) {
      res = await dbClient.insert("Favorite", apod.toMap());
      // TODO: remove debug text
      // print('Favorite added $res');
    } else {
      res = await updateFavorite(apod);
    }
    return res;
  }

  Future<int> deleteFavorite(String date) async {
    var dbClient = await db;
    int res =
        await dbClient.delete("Favorite", where: "date = ?", whereArgs: [date]);
    // TODO: remove debug text
    // print('Favorite was deleted $res');
    return res;
  }

  Future<int> updateFavorite(Apod apod) async {
    var dbClient = await db;
    int res = await dbClient.update("Favorite", apod.toMap(),
        where: "date = ?", whereArgs: [apod.date]);
    // TODO: remove debug text
    // print('Favorite was updated $res for ${apod.date} with ${apod.isFavorite}');
    return res;
  }

  Future<Apod> getApod(String date) async {
    var dbClient = await db;
    Apod apod;
    List<Map> favorite =
        await dbClient.query("Favorite", where: "date = ?", whereArgs: [date]);
    if (favorite.length > 0) {
      apod = Apod.fromDb(favorite[0]);
      // TODO: remove debug text
      // print('Date $date, Favorite ${apod.isFavorite}');
    }
    return apod;
  }

  Future<List<Apod>> getFavoriteApodList() async {
    var dbClient = await db;
    List<Map> res = await dbClient
        .query("Favorite", where: "is_favorite = ?", whereArgs: [1]);
    // TODO: remove debug text
    // print('true lenght: ${res.map((a) => Apodpic.fromDb(a)).toList().length}');
    return res.map((a) => Apod.fromDb(a)).toList();
  }

  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }
}
