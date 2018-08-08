import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:flutter/material.dart';
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

  Widget _buildHistoryListTile() {
    return ListView(
      children: tileBuilder(),
      // itemBuilder: favoriteBuilder,
      // dismissibleItems: true,
      // dismissedCallback: (int index, _) => _removeFavorite(index),
    );
  }

  Widget _buildFavorite() {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: FutureBuilder(
        future: setupList(),
        builder: (_, snapshot) => _buildHistoryListTile(),
      ),
    );
  }

  List<Widget> tileBuilder() {
    final tiles = historyList.map(
      (apod) {
        var titleWidget = Text(apod.title);
        var dateWidget = Text(apod.date);
        // var explanationWidget = Expanded(
        //   child: SingleChildScrollView(
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Text(
        //         apod.explanation,
        //         textAlign: TextAlign.justify,
        //       ),
        //     ),
        //   ),
        // );
        // TODO: handle video content
        var pictureWidget = Container(
          width: 80.0,
          height: 60.0,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: apod.url,
            fit: BoxFit.fill,
            fadeInDuration: Duration(milliseconds: 400),
          ),
        );
        return ListTile(
          title: titleWidget,
          leading: pictureWidget,
          trailing: apod.isFavorite
              ? Icon(
                  Icons.favorite,
                  color: Theme.of(context).primaryColorDark,
                )
              : Icon(Icons.favorite_border),
          subtitle: dateWidget,
          onTap: () {},
        );
      },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return divided;
  }
}
