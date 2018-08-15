import 'dart:async';
import 'dart:convert' as json;
import 'dart:math';

import 'package:apod_viewer/src/exception_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/NASA_Api.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Apod> getApodData(DateTime date, ApodDatabase db) async {
  var apod = await db.getApod(strDate(date));
  if (apod == null) {
    final apiCall = NASAApi(date: date);
    String requestUrl = await apiCall.getUrl().then((String value) => value);
    print(requestUrl);
    final res = await http.get(requestUrl);
    final parsed = json.jsonDecode(res.body);
    switch (res.statusCode) {
      case 200:
        return Apod.fromJson(parsed);
      case 403:
        throw ExceptionHelper(message: parsed['error']['code']);
      case 429:
        throw ExceptionHelper(message: parsed['error']['code']);
    }
  }
  return apod;
}

DateTime getRandomDate() {
  final DateTime minDate = NASAApi.minDate;
  final DateTime maxDate = NASAApi.maxDate;
  final Duration randomRange = maxDate.difference(minDate);
  final int dateDiff = Random().nextInt(randomRange.inDays);
  return minDate.add(Duration(days: dateDiff));
}

String strDate(DateTime date) {
  return date.toString().substring(0, 10);
}

String normalizeUrl(String url) {
  var regex = RegExp(r"http");
  if (regex.hasMatch(url)) {
    var match = regex.allMatches(url).toList();
    if (match.length > 1) {
      url = url.replaceAll(NASAApi.urlPrefix, "");
    }
  }
  return url;
}

Widget getMediaWdiget(Apod apod) {
  switch (apod.mediaType) {
    case "image":
      return GestureDetector(
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
    case "video":
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Container(
                width: 200.0,
                height: 50.0,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.launch),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("Launch Video in Browser"),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              onPressed: () async {
                if (await canLaunch(apod.url)) {
                  launch(apod.url);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Not a picture today.",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      );
    default:
      return Container();
  }
}
