import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../utils/api_key.dart';

class GoogleMapService {
  var uuid = Uuid();
  String sessionToken = '122344';
  GoogleMapService();

  dynamic onChange(TextEditingController _textEditingController) async {
    if (sessionToken == null) {
      sessionToken = uuid.v4();
    }

    var myList = await getSuggetion(_textEditingController.text, sessionToken);

    return myList;
  }

  Future<dynamic> getSuggetion(String input, String sessionToken) async {
    List<dynamic> _placesList = [];
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request =
        '$baseUrl?input=$input&key=$GOOGLE_API_MAP&sessiontoken=$sessionToken';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      _placesList = jsonDecode(response.body.toString())['predictions'];
      return _placesList;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
