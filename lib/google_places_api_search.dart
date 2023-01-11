import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_google_map/const.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class GooglePlacesApiSearchScreen extends StatefulWidget {
  const GooglePlacesApiSearchScreen({super.key});

  @override
  State<GooglePlacesApiSearchScreen> createState() =>
      _GooglePlacesApiSearchScreenState();
}

class _GooglePlacesApiSearchScreenState
    extends State<GooglePlacesApiSearchScreen> {
  TextEditingController _textEditingController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
      print('SESSION:');
      print(_sessionToken);
    }

    getSuggetion(_textEditingController.text);
  }

  getSuggetion(String input) async {
    String googleKey = MyConstantVariables.GOOGLE_API_MAP;

    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request =
        '$baseUrl?input=$input&key=$googleKey&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Google Search Places Api'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration(hintText: 'Search Places with name'),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _placesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_placesList[index]['description']),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
