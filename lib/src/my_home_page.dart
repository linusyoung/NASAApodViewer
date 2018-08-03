import 'dart:async';

import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:simple_coverflow/simple_coverflow.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/data_fetch.dart';

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
  Apod apod;
  final _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  List<Apod> favoriteList = List();
  List<Apod> cacheFavoriteList = List();

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
    var _asyncLoader = AsyncLoader(
      key: _asyncLoaderState,
      initState: () async {
        apod = await getApodData(_picDate, db);
      },
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) => Text(
          'Sorry, there was an error when loading APOD data. Please try other date.'),
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
                  initialDate: _selectedDate,
                ).then((DateTime value) {
                  if (value != null) {
                    _selectedDate = value;
                    _picDate = value.toString().substring(0, 10);
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
            apod.isFavorite = true;
            await db.addFavorite(apod);
            await setupList();
            print("list lenght: ${cacheFavoriteList.length}");
            Scaffold.of(context).showSnackBar(snackBar);
          }),
    );
  }

  Future setupList() async {
    favoriteList = await db.getFavoriteApodList();
    print(cacheFavoriteList.length);
    setState(() {
      cacheFavoriteList = favoriteList;
    });
  }

// TODO: move favorite to a separate class
  void _showFavorite() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Favorite'),
          ),
          body: CoverFlow(
            itemBuilder: favoriteBuilder,
          ),
        );
      }),
    );
  }

  Widget favoriteBuilder(BuildContext context, int index) {
    final cards = favoriteList.map(
      (apod) {
        var titleWidget = Text(apod.title);
        var dateWidget = Text(apod.date);
        var explanationWidget = Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                apod.explanation,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        );
        var pictureWidget = FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: apod.url,
          fit: BoxFit.fitHeight,
        );
        return Container(
          child: Card(
              margin: EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
              ),
              child: Column(
                children: <Widget>[
                  dateWidget,
                  titleWidget,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pictureWidget,
                  ),
                  explanationWidget,
                ],
              )),
        );
      },
    ).toList();

    if (cards.length == 0) {
      return new Container();
    } else {
      return cards[index % cards.length];
    }
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
    var imageWidget = GestureDetector(
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

    var explanationWidget = Text(
      apod.explanation,
      softWrap: true,
      textAlign: TextAlign.justify,
    );

    return ListView(
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
                child: imageWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: explanationWidget,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
