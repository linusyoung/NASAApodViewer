import 'dart:async';

import 'package:apod_viewer/src/favorite_page.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/data_util.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _picDate = DateTime.now();
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
    _isShakable = true;
    accelerometerEvents.listen((AccelerometerEvent event) async {
      if ((event.x.abs() >= 10 && event.y.abs() >= 10) && _isShakable) {
        _picDate = getRandomDate();
        _asyncLoaderState.currentState.reloadState();
        _isShakable = false;
        await Future.delayed(Duration(seconds: 10), () => _isShakable = true);
      }
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = AsyncLoader(
      key: _asyncLoaderState,
      initState: () async {
        apod = await getApodData(_picDate, db);
      },
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) {
        var errWidget;

        if (NASAApi.maxDate.difference(_picDate).isNegative) {
          // TODO: format error msg
          errWidget = Text(
              'Sorry, there was an error when loading APOD data. Please try other date.');
        } else {
          errWidget = Center(
            child: Text('Tomorrow is not coming yet. Please be patient!'),
          );
        }
        return errWidget;
      },
      renderSuccess: ({data}) {
        return _getApodContent();
      },
    );
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
                  initialDate: _picDate,
                ).then((DateTime value) {
                  if (value != null) {
                    _picDate = value;
                    _asyncLoaderState.currentState.reloadState();
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
          onPressed: _showFavorite,
        ),
      ),
      body: _asyncLoader,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.favorite),
        onPressed: _addFavorite,
      ),
    );
  }

  Widget _getApodContent() {
    var titleWidget = Text(
      apod.title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
    );
    var dateWidget = Text(
      apod.date,
      style: TextStyle(),
    );
    var copyrightWidget = Text(
      apod.copyright,
      overflow: TextOverflow.ellipsis,
    );
    var mediaWidget = _getMediaWdiget(apod.mediaType);

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
        if (NASAApi.maxDate.difference(_picDate).isNegative) {
          setState(() {});
        } else {
          _asyncLoaderState.currentState.reloadState();
        }
      },
      child: NASAApi.maxDate.difference(_picDate).isNegative
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Tomorrow is not coming!\nSwipe back or select a date from Calendar.',
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: titleWidget,
                            ),
                          ],
                        ),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: mediaWidget,
                      ),
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

  Widget _getMediaWdiget(String mediaType) {
    print(apod.url);
    switch (mediaType) {
      case "image":
        return GestureDetector(
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: apod.url,
            fit: BoxFit.fitWidth,
            fadeInDuration: Duration(milliseconds: 400),
          ),
          onLongPress: () async {
            if (await canLaunch(apod.hdurl)) {
              launch(apod.hdurl);
            }
          },
        );
      case "video":
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Video can be played in Browser only.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            FloatingActionButton.extended(
              label: Text('Launch in Browser'),
              icon: Icon(Icons.launch),
              onPressed: () async {
                if (await canLaunch(apod.url)) {
                  launch(apod.url);
                }
              },
            ),
          ],
        );
    }
  }

  void _showFavorite() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return Favorite();
      }),
    );
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
