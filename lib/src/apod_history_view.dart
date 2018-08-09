import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

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
    // TODO: handle video content
    var pictureWidget = Container(
      width: 80.0,
      height: 60.0,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: apodState.url,
        fit: BoxFit.fill,
        fadeInDuration: Duration(milliseconds: 400),
      ),
    );

    return ListTile(
      title: titleWidget,
      leading: pictureWidget,
      trailing: IconButton(
        icon: apodState.isFavorite
            ? Icon(
                Icons.favorite,
                color: Theme.of(context).primaryColorDark,
              )
            : Icon(Icons.favorite_border),
        onPressed: _onPressed,
      ),
      subtitle: dateWidget,
    );
  }
}
