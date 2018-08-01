import 'package:apod_viewer/src/apodpic.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'dart:io';

import 'package:apod_viewer/model/model.dart';

class FavoriteDatabase{
  static final FavoriteDatabase _instance = FavoriteDatabase._internal();

  factory FavoriteDatabase() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null){
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  FavoriteDatabase._internal();

  Future<Database> initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,"main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      "CREATE TABLE Favorite(
        PIC_DATE STRING PRIMARY KEY,
        TITLE TEXT,
        COPYRIGHT TEXT,
        EXPLANATION TEXT,
        URL TEXT,
        HDURL TEXT,
        MEDIA_TYPE TEXT,
        SERVICE_VERSION TEXT,
        IS_FAVORITE BIT)"
    ''');
    print('Database Was Created');
  }

  Future<int> addFavorite(Apodpic apod) async {
    var dbClient = await db;
    try{
      int res = await dbClient.insert("Favorite", apod.toMap());
      print('Favorite added $res');
      return res;
    } catch(e){
      int res = await updateFavorite(apod);
      return res;
    }
  }

  Future<int> deleteFavorite(String date) async {
    var dbClient = await db;
    int res = await dbClient.delete("Favorite", where: "PIC_DATE = ?", whereArgs: [date]);
    print('Favorite was deleted $res');
    return res;
  }

  Future<int> updateFavorite(Apodpic apod) async{
    var dbClient = await db;
    int res = await dbClient.update("Favorite", apod.toMap(), where: "PIC_DATE = ?", whereArgs: [apod.date]);
    print('Favorite was updated $res');
    return res;
  }

  Future closeDb() async{
    var dbClient = await db;
    dbClient.close();
  }
}