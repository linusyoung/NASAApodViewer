import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:flutter/material.dart';
import 'package:simple_coverflow/simple_coverflow.dart';
import 'package:transparent_image/transparent_image.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Apod> historyList = List();
  Apod apod;
  ApodDatabase db = ApodDatabase();

  @override
  void initState() {
    super.initState();
    historyList = [];
  }

  @override
  Widget build(BuildContext context) {
    return _buildFavorite();
  }

  Future setupList() async {
    historyList = await db.getApodList();
  }

  void _removeFavorite(int index) async {
    var unfavoriteApod = historyList[index % historyList.length];
    unfavoriteApod.isFavorite = false;
    historyList.removeAt(index % historyList.length);
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
        title: Text('History'),
      ),
      body: FutureBuilder(
        future: setupList(),
        builder: (_, snapshot) => _buildCoverFlow(),
      ),
    );
  }

  Widget favoriteBuilder(BuildContext context, int index) {
    final cards = historyList.map(
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
