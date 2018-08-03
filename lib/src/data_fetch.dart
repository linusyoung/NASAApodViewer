import 'dart:async';
import 'dart:convert' as json;
import 'dart:math';

import 'package:apod_viewer/database/database.dart';
import 'package:apod_viewer/model/apodpic.dart';
import 'package:apod_viewer/src/NASAApi.dart';
import 'package:http/http.dart' as http;

Future<Apodpic> getApodData(String date, FavoriteDatabase db) async {
  var apod = await db.getApod(date);
  if (apod == null) {
    final apiCall = NASAApi(date: date);
    final requestUrl = apiCall.getUrl();
    final res = await http.get(requestUrl);

    if (res.statusCode == 200) {
      final parsed = json.jsonDecode(res.body);
      return Apodpic.fromJson(parsed);
    } else {
      throw Exception('Fail to get pictures;');
    }
  } else {
    return apod;
  }
}

String getRandomDate() {
  final DateTime minDate = NASAApi.minDate;
  final DateTime maxDate = NASAApi.maxDate;
  final Duration randomRange = maxDate.difference(minDate);
  final int dateDiff = Random().nextInt(randomRange.inDays);
  return minDate.add(Duration(days: dateDiff)).toString().substring(0, 10);
}
