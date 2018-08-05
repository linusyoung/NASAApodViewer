import 'package:apod_viewer/src/data_util.dart';

class NASAApi {
  static const String API_KEY = "2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl";
  static const String BASE_URL = "https://api.nasa.gov/planetary/apod?";
  static DateTime minDate = DateTime(1995, 6, 20);
  static DateTime maxDate = DateTime.now();

  DateTime date;

  NASAApi({this.date});

  String getUrl() {
    return BASE_URL +
        'api_key=' +
        API_KEY +
        '&date=' +
        strDate(this.date) +
        '&hd=true';
  }
}
