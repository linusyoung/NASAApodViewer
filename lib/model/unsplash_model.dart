class UnsplashPhoto {
  final String smallUrl;
  final String fullUrl;
  final String userName;
  final String userHtml;
  static const String baseUrl = "https://api.unsplash.com/";

  UnsplashPhoto({this.smallUrl, this.fullUrl, this.userName, this.userHtml});

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return UnsplashPhoto(
      smallUrl: json['urls']['small'],
      fullUrl: json['links']['download'],
      userName:
          "${json['user']['first_name'] ?? ""} ${json['user']['last_name'] ?? ""}",
      userHtml: json['links']['html'],
    );
  }
}
