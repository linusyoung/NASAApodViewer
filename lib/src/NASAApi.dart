class NASAApi {
  static const API_KEY = "2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl";
  static const BASE_URL ="https://api.nasa.gov/planetary/apod?";

  NASAApi();
  
  String getUrl(){
    final requestUrl = BASE_URL + 'api_key=' + API_KEY;
    return requestUrl;
  }
}