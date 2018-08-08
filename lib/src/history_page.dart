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
    return _buildHistory();
  }

  Future setupList() async {
    historyList = await db.getApodList();
  }

  Widget _buildHistory() {
    var futureBuilder = FutureBuilder(
      future: db.getApodList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return buildListView(context, snapshot);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: futureBuilder,
    );
  }

  Widget _buildRow(Apod apod) {
    var titleWidget = Text(apod.title);
    var dateWidget = Text(apod.date);
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
      onTap: () async {
        await db.updateFavorite(apod);
        setState(() {});
      },
    );
  }

  Widget buildListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Apod> apods = snapshot.data;
    return ListView.builder(
        itemCount: apods.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          return _buildRow(apods[index]);
        });
  }
}
