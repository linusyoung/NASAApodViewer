import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:simple_coverflow/simple_coverflow.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Apod> favoriteList = List();
  Apod apod;
  ApodDatabase db = ApodDatabase();

  @override
  void initState() {
    super.initState();
    favoriteList = [];
  }

  @override
  Widget build(BuildContext context) {
    return _buildFavorite();
  }

  Future setupList() async {
    favoriteList = await db.getFavoriteApodList();
  }

  void _removeFavorite(int index) async {
    var unfavoriteApod = favoriteList[index % favoriteList.length];
    unfavoriteApod.isFavorite = false;
    favoriteList.removeAt(index % favoriteList.length);
    await db.updateApod(unfavoriteApod);
    _buildFavorite();
  }

  Widget _buildCoverFlow() {
    return CoverFlow(
      itemBuilder: favoriteBuilder,
      dismissibleItems: true,
      dismissedCallback: (int index, _) => _removeFavorite(index),
    );
  }

  Widget _buildFavorite() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: FutureBuilder(
        future: setupList(),
        builder: (_, snapshot) => _buildCoverFlow(),
      ),
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
        // TODO: handle video content
        var pictureWidget = FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: apod.url,
          fit: BoxFit.fitWidth,
          fadeInDuration: Duration(milliseconds: 400),
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
}
