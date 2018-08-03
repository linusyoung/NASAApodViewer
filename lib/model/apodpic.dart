//TODO: move this to model.dart
class Apodpic {
  final String copyright;
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;
  bool isFavorite;

  Apodpic(
      {this.copyright,
      this.date,
      this.explanation,
      this.hdurl,
      this.mediaType,
      this.serviceVersion,
      this.title,
      this.url,
      this.isFavorite});

  factory Apodpic.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Apodpic(
        date: json['date'],
        copyright:
            json['copyright'] == null ? '' : '\u00a9' + json['copyright'],
        explanation: json['explanation'],
        hdurl: json['hdurl'],
        mediaType: json['media_type'],
        serviceVersion: json['service_version'],
        title: json['title'],
        url: json['url'],
        isFavorite: false);
  }

  factory Apodpic.fromDb(Map map) {
    return Apodpic(
        date: map['date'],
        copyright: map['copyright'] == null ? '' : '\u00a9' + map['copyright'],
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
