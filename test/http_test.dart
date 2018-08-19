// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:club.swimmingbeaver.apodviewerflutter/model/NASA_Api.dart';
import 'package:club.swimmingbeaver.apodviewerflutter/src/data_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('String date', () {
    final today = DateTime.now();
    final expected = today.toString().substring(0, 10);
    expect(strDate(today), expected);
  });

  test('Nasa API request url', () {
    final today = strDate(DateTime.now());
    expect(NASAApi(date: DateTime.now()).getUrl(),
        "https://api.nasa.gov/planetary/apod?api_key=2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl\&date=$today\&hd=true");
  });

  test('Url normalize', () {
    final testUrl = "https://apod.nasa.gov/apod/image/sdfadf";
    expect(normalizeUrl(testUrl), "https://apod.nasa.gov/apod/image/sdfadf");
  });
}
