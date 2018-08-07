import 'package:apod_viewer/src/data_util.dart';

class NASAApi {
  static const String apiKey = "2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl";
  static const String baseUrl = "https://api.nasa.gov/planetary/apod?";
  static DateTime minDate = DateTime(1995, 6, 20);
  static DateTime maxDate = DateTime.now();
  static const String urlPrefix = "https://apod.nasa.gov/apod/";
  DateTime date;

  NASAApi({this.date});

  String getUrl() {
    var dateStr = strDate(date);
    return "${baseUrl}api_key=$apiKey\&date=$dateStr\&hd=true";
  }
}
