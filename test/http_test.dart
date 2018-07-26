// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'dart:convert' as json;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:apod_viewer/src/apodpic.dart';

void main() {
  test('Get picture json from NASA', () async {
    final baseUrl = 'https://api.nasa.gov/planetary/apod?';
    final apiKey = 'DEMO_KEY';
    final requestUrl = baseUrl + 'api_key=' + apiKey;
    print(requestUrl);
    final res = await http.get(requestUrl);
    if (res.statusCode == 200){
      final picJson = json.jsonDecode(res.body);
      final apod = Apodpic.fromJson(picJson);
      print(apod.date);
      expect(apod.date, '2018-07-26');
    }
  });
}
