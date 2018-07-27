
class NASAApi {
  static const API_KEY = "2bHuLGYETr9kzcrkqRWBqlJOP1c1AYfMXilVkeAl";
  static const BASE_URL ="https://api.nasa.gov/planetary/apod?";

  String date;

  NASAApi(){
    this.date = null;
  }

  NASAApi.hasDate({this.date});

  String getUrl(){
    var requestUrl;
    if (date == null){
      requestUrl = BASE_URL + 'api_key=' + API_KEY;
    } else {
      requestUrl = BASE_URL + 'api_key=' + API_KEY + '&date=' +date;
    } 
    return requestUrl;
  }
}