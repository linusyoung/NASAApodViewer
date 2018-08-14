import 'dart:async';

import 'package:apod_viewer/model/app_actions.dart';
import 'package:apod_viewer/src/favorite_page.dart';
import 'package:apod_viewer/src/history_page.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/data_util.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const actions = <Actions>[
    Actions(icon: Icons.date_range, semanticLabel: "select date"),
    Actions(icon: Icons.list, semanticLabel: "favorite list"),
    Actions(icon: Icons.history, semanticLabel: "History"),
  ];

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _apiKey;

  Future<Null> _setApiKey(String apiKey) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("api_key", apiKey);
  }

  Future<String> _getApiKey() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString("api_key");
  }

  DateTime _picDate;
  bool _isShakable;
  ApodDatabase db;
  Apod apod;
  final _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  List<Apod> favoriteList = List();

  @override
  void initState() {
    super.initState();
    db = ApodDatabase();
    db.initDb();
    _picDate = NASAApi.maxDate;
    _isShakable = true;
    _setApiKey("DEMO_key");
    accelerometerEvents.listen((AccelerometerEvent event) async {
      if ((event.x.abs() >= 10 && event.y.abs() >= 10) && _isShakable) {
        _picDate = getRandomDate();
        _asyncLoaderState.currentState.reloadState();
        _isShakable = false;
        await Future.delayed(Duration(seconds: 10), () => _isShakable = true);
      }
    });
  }

  Future<String> getUserApiKeyDialog(BuildContext context) {
    return showDialog<String>(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 150.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text("Please provide your NASA API key below:"),
                    Center(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "NASA API key",
                        ),
                        autofocus: true,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Done"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        RaisedButton(
                          child: Text("NASA"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (await canLaunch(NASAApi.nasaApiKeyUrl)) {
                              launch(NASAApi.nasaApiKeyUrl);
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final lastDate = NASAApi.maxDate;
    var _asyncLoader = AsyncLoader(
      key: _asyncLoaderState,
      initState: () async {
        apod = await getApodData(_picDate, db);
        await db.updateApod(apod);
      },
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) {
        return Center(
          child: Text(
              'Sorry, there was an error when loading APOD data. Please try other date.'),
        );
      },
      renderSuccess: ({data}) {
        return _getApodContent();
      },
    );
    var drawer = Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
                title: Text(
              "Settings",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
          Divider(),
          ListTile(
            title: Text('Use your own API key'),
            leading: Icon(Icons.vpn_key),
            onTap: () {
              Navigator.pop(context);
              getUserApiKeyDialog(context);
            },
          ),
        ],
      ),
    );

    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                actions[0].icon,
                semanticLabel: actions[0].semanticLabel,
              ),
              onPressed: () {
                showDatePicker(
                  context: context,
                  firstDate: NASAApi.minDate,
                  lastDate: lastDate,
                  initialDate: _isFuture() ? lastDate : _picDate,
                ).then((DateTime value) {
                  if (value != null) {
                    _picDate = value;
                    _asyncLoaderState.currentState.reloadState();
                  }
                });
              }),
          IconButton(
            icon: Icon(
              actions[1].icon,
              semanticLabel: actions[1].semanticLabel,
            ),
            onPressed: _showFavorite,
          ),
          IconButton(
            icon: Icon(
              actions[2].icon,
              semanticLabel: actions[2].semanticLabel,
            ),
            onPressed: _showHistory,
          ),
          // TODO: test icon remove later
          IconButton(
            icon: Icon(
              Icons.ac_unit,
            ),
            onPressed: () async {
              final SharedPreferences prefs = await _prefs;
              final String apiKey = prefs.getString("api_key");
              print(apiKey);
            },
          ),
        ],
      ),
      body: _asyncLoader,
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.favorite),
        onPressed: _addFavorite,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _getApodContent() {
    var titleWidget = Text(
      apod.title,
      // overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      textAlign: TextAlign.center,
    );
    var dateWidget = Text(
      apod.date,
      style: TextStyle(),
    );
    var copyrightWidget = Text(
      apod.copyright != '' ? '\u00a9${apod.copyright}' : '',
      overflow: TextOverflow.ellipsis,
    );
    var mediaWidget = getMediaWdiget(apod);

    var explanationWidget = Text(
      apod.explanation,
      softWrap: true,
      textAlign: TextAlign.justify,
    );

    return Dismissible(
      key: ValueKey(_picDate),
      onDismissed: (DismissDirection direction) {
        var _dayDiff = 0;
        _dayDiff += direction == DismissDirection.endToStart ? 1 : -1;
        _picDate = _picDate.add(Duration(days: _dayDiff));
        if (_isFuture()) {
          setState(() {});
        } else {
          _asyncLoaderState.currentState.reloadState();
        }
      },
      child: _isFuture()
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${strDate(_picDate)} isn\'t available!\nSwipe right or select a date from Calendar.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: titleWidget,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            dateWidget,
                            Flexible(
                              child: copyrightWidget,
                            ),
                          ],
                        ),
                      ),
                      Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            apod.mediaType == 'image'
                                ? CircularProgressIndicator()
                                : Container(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: mediaWidget,
                            ),
                          ]),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: explanationWidget,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  bool _isFuture() {
    return NASAApi.maxDate.difference(_picDate).isNegative;
  }

  void _showFavorite() {
    _isShakable = false;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return Favorite();
      }),
    ).then((_) {
      _isShakable = true;
    });
  }

  void _showHistory() {
    _isShakable = false;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return History();
      }),
    ).then((_) {
      _isShakable = true;
    });
  }

  void _addFavorite() async {
    apod.isFavorite = true;
    await db.updateApod(apod);
    Fluttertoast.showToast(
      msg: "Favorite Added!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }
}
