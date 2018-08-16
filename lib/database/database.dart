import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:club.swimmingbeaver.apodviewerflutter/model/apod_model.dart';

class ApodDatabase {
  static final ApodDatabase _instance = ApodDatabase._internal();

  factory ApodDatabase() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  ApodDatabase._internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "main.db");
    var theDb = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return theDb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('''CREATE TABLE APIKey(
      api_key TEXT PRIMARY KEY,
      key_type TEXT
    )''');
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

    await db.execute('''CREATE TABLE APIKey(
      api_key TEXT PRIMARY KEY,
      key_type TEXT
    )''');
  }

  Future<int> updateApod(Apod apod) async {
    var dbClient = await db;
    int res;
    List<Map> exist = await dbClient
        .query("Favorite", where: "date = ?", whereArgs: [apod.date]);
    if (exist.length == 0) {
      res = await dbClient.insert("Favorite", apod.toMap());
      // TODO: remove debug text
      print('Apod added $res');
    } else {
      res = await updateFavorite(apod);
      print('Apod updated');
    }
    return res;
  }

  Future<int> updateApiKey(String apiKey) async {
    var dbClient = await db;
    int res;
    var map = Map<String, dynamic>();
    map['api_key'] = apiKey;
    map['key_type'] = "user";
    List<Map> exist = await dbClient
        .query("APIKey", where: "key_type = ?", whereArgs: ["user"]);
    if (exist.length == 0) {
      res = await dbClient.insert("APIKey", map);
      // TODO: remove debug text
      print('Apikey added $res');
    } else {
      res = await dbClient.update("APIKey", map);
      print('Apikey updated');
    }
    return res;
  }

  Future<String> getUserApiKey() async {
    var dbClient = await db;
    String apiKey;
    List<Map> res = await dbClient
        .query("APIKey", where: "key_type = ?", whereArgs: ["user"]);
    if (res.length > 0) {
      apiKey = res[0]['api_key'];
    }
    return apiKey;
  }

  Future<int> updateFavorite(Apod apod) async {
    var dbClient = await db;
    int res = await dbClient.update("Favorite", apod.toMap(),
        where: "date = ?", whereArgs: [apod.date]);
    // TODO: remove debug text
    print('Favorite was updated $res for ${apod.date} with ${apod.isFavorite}');
    return res;
  }

  Future<Apod> getApod(String date) async {
    var dbClient = await db;
    Apod apod;
    List<Map> favorite =
        await dbClient.query("Favorite", where: "date = ?", whereArgs: [date]);
    if (favorite.length > 0) {
      apod = Apod.fromDb(favorite[0]);
    }
    return apod;
  }

  Future<List<Apod>> getFavoriteApodList() async {
    var dbClient = await db;
    List<Map> res = await dbClient.query("Favorite",
        where: "is_favorite = ?", whereArgs: [1], orderBy: "date");
    // TODO: remove debug text
    // print('favorite lenght: ${res.map((a) => Apod.fromDb(a)).toList().length}');
    return res.map((a) => Apod.fromDb(a)).toList();
  }

  Future<List<Apod>> getApodList() async {
    var dbClient = await db;
    List<Map> res = await dbClient.query("Favorite", orderBy: "date");
    // TODO: remove debug text
    print('apod lenght: ${res.map((a) => Apod.fromDb(a)).toList().length}');
    return res.map((a) => Apod.fromDb(a)).toList();
  }

  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }
}
