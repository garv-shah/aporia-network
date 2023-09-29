import 'dart:convert';

import 'package:http/http.dart' as http;

class Network {
  final Uri url;

  Network(this.url);

  Future<String> sendData(Map data) async {
    http.Response response = await http.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }

  Future<String> getData() async {
    http.Response response = await http.post(url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }
}

Future<String> getCountry() async{
  Network n = Network(Uri.parse("http://ip-api.com/json"));
  String locationSTR = (await n.getData());
  dynamic locationx = jsonDecode(locationSTR);
  return locationx["country"];
}
