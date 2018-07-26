class Apodpic {
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;

  const Apodpic(
      {this.date,
      this.explanation,
      this.hdurl,
      this.mediaType,
      this.serviceVersion,
      this.title,
      this.url});

  factory Apodpic.fromJson(Map<String, dynamic> json){
    if (json == null) 
      return null;
    
    return Apodpic(
      date: json['date'],
      explanation: json['explanation'],
      hdurl: json['hdurl'],
      mediaType: json['media_type'],
      serviceVersion: json['service_version'],
      title: json['title'],
      url: json['url']
    );
  }
}
