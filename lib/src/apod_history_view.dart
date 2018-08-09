import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/data_util.dart';
import 'package:flutter/material.dart';

class ApodHistoryView extends StatefulWidget {
  final Apod apod;
  ApodHistoryView({this.apod});

  @override
  _ApodHistoryViewState createState() => _ApodHistoryViewState();
}

class _ApodHistoryViewState extends State<ApodHistoryView> {
  Apod apodState;

  @override
  void initState() {
    super.initState();
    apodState = widget.apod;
    var db = ApodDatabase();
    db.getApod(apodState.date).then((apod) {
      setState(() => apodState.isFavorite = apod.isFavorite);
    });
  }

  void _onPressed() {
    var db = ApodDatabase();
    setState(() => apodState.isFavorite = !apodState.isFavorite);
    db.updateApod(apodState);
  }

  @override
  Widget build(BuildContext context) {
    var titleWidget = Text(apodState.title);
    var dateWidget = Text(apodState.date);
    var explanationWidget = Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            apodState.explanation,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );

    var mediaWidget = getMediaWdiget(apodState);
    return ExpansionTile(
      initiallyExpanded: false,
      title: Container(
        height: 80.0,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                child: dateWidget,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: titleWidget,
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: apodState.isFavorite
            ? Icon(
                Icons.favorite,
                color: Theme.of(context).primaryColorDark,
              )
            : Icon(Icons.favorite_border),
        onPressed: _onPressed,
      ),
      children: <Widget>[mediaWidget, explanationWidget],
    );
  }
}
