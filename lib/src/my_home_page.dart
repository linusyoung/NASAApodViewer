import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apodpic.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  String _picDate = DateTime.now().toLocal().toString().substring(0, 10);
  // bool _isShakable = false;
  FavoriteDatabase db;
  Apodpic apodpic;

  List<Apodpic> favoriteList = List();
  List<Apodpic> cacheFavoriteList = List();

  @override
  void initState() {
    super.initState();
    db = FavoriteDatabase();
    db.initDb();
    favoriteList = [];
    cacheFavoriteList = [];
    // TODO: shake disabled. better implementation later.
    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   if (event.x.abs() >= 3.0 && !_isShakable) {
    //     setState(() {
    //       _picDate = getRandomDate();
    //       _isShakable = true;
    //     });
    //   }
    //   if (_isShakable) {
    //     Timer(Duration(milliseconds: 4000), () {
    //       _isShakable = false;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    db.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: ListView(
        children: <Widget>[
          Center(
            child: FutureBuilder<Apodpic>(
              future: getApodData(_picDate, db),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  apodpic = snapshot.data;
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                apodpic.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                apodpic.date,
                                style: TextStyle(),
                              ),
                              // TODO: handle non copyright layout better/overflow copyright
                              Text(apodpic.copyright),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: GestureDetector(
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: snapshot.data.url,
                            fit: BoxFit.fitWidth,
                            fadeInDuration: Duration(milliseconds: 400),
                          ),
                          onLongPress: () async {
                            if (await canLaunch(snapshot.data.hdurl)) {
                              launch(snapshot.data.hdurl);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          snapshot.data.explanation,
                          softWrap: true,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  // TODO: build widget to display when error incurred.
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.favorite),
          onPressed: () async {
            final snackBar = SnackBar(
              content: Text('Favorite Added!'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: add undo function
                },
              ),
            );
            apodpic.isFavorite = true;
            await db.addFavorite(apodpic);
            await setupList();
            print("list lenght: ${cacheFavoriteList.length}");
            Scaffold.of(context).showSnackBar(snackBar);
          }),
    );
  }

  AppBar getAppBar() {
    return AppBar(
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
        onPressed: _showFavorite,
      ),
    );
  }

  // TODO: favorite icon is not changed based on database.
  Widget checkFavorite() {
    Icon icon;
    setState(() {
      if (apodpic == null) {
        icon = Icon(Icons.favorite);
      } else {
        icon = apodpic.isFavorite
            ? Icon(Icons.favorite)
            : Icon(Icons.favorite_border);
      }
    });
    return icon;
  }

  Future setupList() async {
    favoriteList = await db.getFavoriteApodList();
    print(cacheFavoriteList.length);
    setState(() {
      cacheFavoriteList = favoriteList;
    });
  }

  void _showFavorite() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final tiles = favoriteList.map(
            (apod) {
              return ListTile(
                title: Text(
                  apod.title,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Favorite'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

//   final tiles = _saved.map(
//     (pair) {
//       return ListTile(
//         title: Text(
//           pair.asPascalCase,
//           style: _biggerFont,
//         ),
//       );
//     },
//   );
//   final divided = ListTile.divideTiles(
//     context: context,
//     tiles: tiles,
//   ).toList();
