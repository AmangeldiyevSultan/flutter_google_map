import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/api_key.dart';

class PlacesInfo {
  static Future<List<String>> getPlacesId(LatLng coordinates) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${coordinates.latitude},${coordinates.longitude}&key=$GOOGLE_API_MAP&radius=100";
    var response = await http.get(Uri.parse(url));
    List<dynamic> json = jsonDecode(response.body)["results"];
    List<String> placesId = [];
    json.forEach((element) {
      placesId.add(element["place_id"]);
    });
    return placesId;
  }

  static Future<List<dynamic>> getPlaces(List<String> placesId) async {
    List res = [];
    for (var i = 0; i < placesId.length; i++) {
      final String uri =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${placesId[i]}&key=$GOOGLE_API_MAP";
      var response = await http.get(Uri.parse(uri));
      var json = jsonDecode(response.body)["result"];
      res.add(json);
    }
    return res;
  }
}
