import 'package:apod_viewer/src/data_util.dart';

class Apod {
  final String copyright;
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;
  bool isFavorite;

  Apod(
      {this.copyright,
      this.date,
      this.explanation,
      this.hdurl,
      this.mediaType,
      this.serviceVersion,
      this.title,
      this.url,
      this.isFavorite});

  factory Apod.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Apod(
        date: json['date'],
        copyright: json['copyright'] == null ? '' : json['copyright'],
        explanation: json['explanation'],
        hdurl: json['hdurl'] == null ? '' : normalizeUrl(json['hdurl']),
        mediaType: json['media_type'],
        serviceVersion: json['service_version'],
        title: json['title'],
        url: normalizeUrl(json['url']),
        isFavorite: false);
  }

  factory Apod.fromDb(Map map) {
    return Apod(
        date: map['date'],
        copyright: map['copyright'] == null ? '' : map['copyright'],
        explanation: map['explanation'],
        hdurl: map['hdurl'],
        mediaType: map['media_type'],
        serviceVersion: map['service_version'],
        title: map['title'],
        url: map['url'],
        isFavorite: map['is_favorite'] == 1 ? true : false);
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['date'] = date;
    map['title'] = title;
    map['explanation'] = explanation;
    map['copyright'] = copyright;
    map['url'] = url;
    map['hdurl'] = hdurl;
    map['is_favorite'] = isFavorite;
    map['service_version'] = serviceVersion;
    map['media_type'] = mediaType;
    return map;
  }
}
