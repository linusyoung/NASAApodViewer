import 'dart:async';
import 'dart:convert' as json;

import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/apodpic.dart';
import 'package:http/http.dart' as http;

Future<Apodpic> getApodData(String date) async {
  final apiCall = NASAApi(date: date);
  final requestUrl = apiCall.getUrl();
  final res = await http.get(requestUrl);
  // TODO: remove debug
  print(requestUrl);
  if (res.statusCode == 200) {
    final parsed = json.jsonDecode(res.body);
    return Apodpic.fromJson(parsed);
  } else {
    throw Exception('Fail to get pictures;');
  }
}

String getRandomDate() {
  final DateTime minDate = DateTime(1995, 6, 20);
  final DateTime maxDate = DateTime.now().toLocal();
  final Duration randomRange = maxDate.difference(minDate);
  final int dateDiff = Random().nextInt(randomRange.inDays);
  return minDate.add(Duration(days: dateDiff)).toString().substring(0,10);
}
