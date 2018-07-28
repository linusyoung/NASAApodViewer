import 'package:apod_viewer/src/apodpic.dart';
import 'package:apod_viewer/src/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentBody extends StatefulWidget {
  final String picDate;
  ContentBody({this.picDate});
  @override
  _ContentBody createState() => _ContentBody();
}

class _ContentBody extends State<ContentBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: FutureBuilder<Apodpic>(
            future: getApodData(widget.picDate),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              snapshot.data.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
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
                              snapshot.data.date,
                              style: TextStyle(),
                            ),
                            // TODO: handle non copyright layout better
                            Text(snapshot.data.copyright),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: GestureDetector(
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: snapshot.data.url,
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
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }
}
