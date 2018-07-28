
class NASAApi {
  static const API_KEY = "2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl";
  static const BASE_URL ="https://api.nasa.gov/planetary/apod?";

  String date;

  NASAApi({this.date});

  String getUrl(){
    return BASE_URL + 'api_key=' + API_KEY + '&date=' +this.date + '&hd=true';
  }
}