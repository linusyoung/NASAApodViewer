import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/content_body.dart';
import 'package:apod_viewer/src/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: new MyHomePage(title: 'NASA APOD Viewer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  String _picDate = DateTime.now().toLocal().toString().substring(0, 10);
  bool _isShakable = false;
  bool _isFavorite = false;
  FavoriteDatabase db;

  @override
  void initState() {
    super.initState();
    db = FavoriteDatabase();
    db.initDb();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() >= 3.0 && !_isShakable) {
        setState(() {
          // TODO: handle multiple times of shacking
          _picDate = getRandomDate();
          _isShakable = true;
        });
      }
      if (_isShakable) {
        Timer(Duration(milliseconds: 4000), () {
          _isShakable = false;
        });
      }
    });
  }

  @override
  void dispose() {
    db.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleSpacing: 1.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () {
                showDatePicker(
                  context: context,
                  firstDate: NASAApi.minDate,
                  lastDate: NASAApi.maxDate,
                  initialDate: _selectedDate,
                ).then((DateTime value) {
                  if (value != null) {
                    _selectedDate = value;
                    setState(() {
                      _picDate = value.toString().substring(0, 10);
                      _isFavorite = db.isFavorite(_picDate);
                    });
                  }
                });
              }),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        ),
      ),
      body: ListView(children: <Widget>[
        ContentBody(
          picDate: _picDate,
          db: db,
          addFavorite: _isFavorite,
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          child:
              _isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          }),
    );
  }
}
