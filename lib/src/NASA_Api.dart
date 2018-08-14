import 'dart:async';

import 'package:apod_viewer/src/data_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NASAApi {
  static const String nasaApiKeyUrl =
      "https://api.nasa.gov/index.html#apply-for-an-api-key";
  static const String apiKey = "DEMO_KEY";
  static const String baseUrl = "https://api.nasa.gov/planetary/apod";
  static DateTime minDate = DateTime(1995, 6, 16);
  // DateTime maxDate;
  // Nasa Apod server on UTC-5
  static DateTime maxDate = DateTime.parse(
      strDate(DateTime.now().toUtc().subtract(Duration(hours: 5))));
  static const String urlPrefix = "https://apod.nasa.gov/apod/";
  DateTime date;

  NASAApi({this.date});

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> getUrl() async {
    String dateStr = strDate(date);
    final SharedPreferences prefs = await _prefs;
    String userApiKey = prefs.getString("api_key");

    return "$baseUrl?api_key=${userApiKey ?? apiKey}\&date=$dateStr";
  }
}
