import 'package:apod_viewer/src/data_util.dart';

class NASAApi {
  static const String apiKey = "<YOUR KEY HERE>";
  static const String baseUrl = "https://api.nasa.gov/planetary/apod";
  static DateTime minDate = DateTime(1995, 6, 16);
  // Nasa Apod server on UTC-5
  static DateTime maxDate = DateTime.now().toUtc().subtract(Duration(hours: 5));
  static const String urlPrefix = "https://apod.nasa.gov/apod/";
  DateTime date;

  NASAApi({this.date});

  String getUrl() {
    var dateStr = strDate(date);
    return "$baseUrl?api_key=$apiKey\&date=$dateStr";
  }
}
