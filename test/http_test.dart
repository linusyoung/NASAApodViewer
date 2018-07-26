// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'dart:convert' as json;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:apod_viewer/src/apodpic.dart';
import 'package:apod_viewer/src/NASAApi.dart';

void main() {
  test('Get picture json from NASA', () async {
    final apiCall = NASAApi();
    final requestUrl = apiCall.getUrl();
    print(requestUrl);
    final res = await http.get(requestUrl);
    if (res.statusCode == 200){
      final parsed = json.jsonDecode(res.body);
      final apod = Apodpic.fromJson(parsed);
      expect(apod.date, '2018-07-26');
    }
  });
}
