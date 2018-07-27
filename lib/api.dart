import 'dart:async';
import 'dart:convert' as json;

import 'package:apod_viewer/src/NASAApi.dart';
import 'package:apod_viewer/src/apodpic.dart';
import 'package:http/http.dart' as http;

Future<Apodpic> getApodData() async {
  final apiCall = NASAApi();
  final requestUrl = apiCall.getUrl();
  final res = await http.get(requestUrl);
  print(requestUrl);
  if (res.statusCode == 200) {
    final parsed = json.jsonDecode(res.body);
    return Apodpic.fromJson(parsed);
  } else {
    throw Exception('Fail to get pictures;');
  }
}
