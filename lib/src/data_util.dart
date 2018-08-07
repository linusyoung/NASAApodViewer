import 'dart:async';
import 'dart:convert' as json;
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apod_model.dart';
import 'package:apod_viewer/src/NASAApi.dart';

Future<Apod> getApodData(DateTime date, ApodDatabase db) async {
  var apod = await db.getApod(date);
  if (apod == null) {
    final apiCall = NASAApi(date: date);
    final requestUrl = apiCall.getUrl();
    final res = await http.get(requestUrl);

    if (res.statusCode == 200) {
      final parsed = json.jsonDecode(res.body);
      return Apod.fromJson(parsed);
    } else {
      throw Exception('Fail to get pictures;');
    }
  } else {
    return apod;
  }
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

// Future<String> getYoutubeVideoUrl(String url) async {
//   const ytApiUrl = 'http://you-link.herokuapp.com/?url=';
//   // TODO: using regex to handle url in Nasa Api
//   var reqUrl = url.replaceAll("embed/", "watch?v=");
//   reqUrl = reqUrl.replaceAll("?rel=0", "");
//   final res = await http.get(ytApiUrl + reqUrl);
//   if (res.statusCode == 200) {
//     final parsed = json.jsonDecode(res.body);
//     // TODO: only return first url at the moment.
//     return parsed[0]['url'];
//   } else {
//     throw Exception('video link is not found.');
//   }
// }
