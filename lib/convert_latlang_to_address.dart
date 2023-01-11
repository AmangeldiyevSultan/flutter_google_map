import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_google_map/const.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';

class ConvertLatLangToAddress extends StatefulWidget {
  const ConvertLatLangToAddress({super.key});

  @override
  State<ConvertLatLangToAddress> createState() =>
      _ConvertLatLangToAddressState();
}

String address = '';
String addressCode = '';

class _ConvertLatLangToAddressState extends State<ConvertLatLangToAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        centerTitle: true,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Text(
              address,
              style: TextStyle(fontSize: 25),
            )),
            Center(
                child: Text(
              addressCode,
              style: TextStyle(fontSize: 25),
            )),
            GestureDetector(
              onTap: () async {
                List<Placemark> placemarks =
                    await placemarkFromCoordinates(52.2165157, 6.9437819);
                List<Location> locations =
                    await locationFromAddress("Gronausestraat 710, Enschede");
                setState(() {
                  addressCode = locations.last.latitude.toString() +
                      ',  ' +
                      locations.last.longitude.toString();

                  address = placemarks.last.country.toString() +
                      ' ' +
                      placemarks.last.administrativeArea.toString();
                });
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.green),
                child: Center(child: Text("Convert")),
              ),
            )
          ]),
    );
  }
}
