import 'dart:async';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/apod_history_view.dart';
import 'package:flutter/material.dart';

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

  Widget buildListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Apod> apods = snapshot.data;
    return ListView.builder(
        itemCount: apods.length,
        itemBuilder: (context, i) {
          return ApodHistoryView(apod: apods[i]);
        });
  }
}
