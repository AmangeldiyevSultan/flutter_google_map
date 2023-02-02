import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_map/features/services/google_map_service.dart';
import 'package:flutter_google_map/features/services/place_info.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  LocationData? currentLocation;
  StreamSubscription? _locationSubscription;
  GoogleMapController? googleMapController;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  TextEditingController _textEditingController = TextEditingController();
  List<dynamic> _placesList = [];
  List<Marker> markers = [];
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/currentDirection.png")
        .then((icon) => currentIcon = icon);
  }

  @override
  void initState() {
    GoogleMapService googleMapService = GoogleMapService();
    super.initState();
    _textEditingController.addListener(() async {
      _placesList = await googleMapService.onChange(_textEditingController);

      setState(() {});
    });
    getCurrentLocation();
    setCustomMarkerIcon();
  }

  @override
  void dispose() {
    super.dispose();
    googleMapController!.dispose();
    _locationSubscription!.cancel();
    _textEditingController.dispose();
  }

  void getCurrentLocation() async {
    try {
      Location location = Location();
      currentLocation = await location.getLocation();
      setState(() {});
      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }
      _locationSubscription = location.onLocationChanged.listen((newLoc) async {
        currentLocation = newLoc;
        if (googleMapController != null) {
          googleMapController!.moveCamera(CameraUpdate.newLatLng(
              LatLng(newLoc.latitude!, newLoc.longitude!)));
        }
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
          body: Column(children: [
        Container(
          decoration: BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Search Places with name'),
          ),
        ),
        if (_placesList.isNotEmpty)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color:
                      _placesList.isEmpty ? Colors.transparent : Colors.white),
              child: ListView.builder(
                  itemCount: _placesList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        List<geo.Location> loc = await geo.locationFromAddress(
                            _placesList[index]['description']);
                        markers.add(
                          Marker(
                              markerId: MarkerId('${loc[0].latitude}'),
                              position:
                                  LatLng(loc[0].latitude, loc[0].longitude),
                              infoWindow: InfoWindow(
                                  title: "More info?",
                                  onTap: () async {
                                    var res = await PlacesInfo.getPlacesId(
                                        LatLng(
                                            loc[0].latitude, loc[0].longitude));
                                    await Navigator.push(
                                        (context),
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                GoogleMapScreen())));
                                  })),
                        );
                        _textEditingController.text = '';
                      },
                      child: ListTile(
                        title: Text(_placesList[index]['description']),
                      ),
                    );
                  }),
            ),
          ),
        if (_placesList.isEmpty)
          Expanded(
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  zoom: 13.5),
              onTap: ((argument) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Marker"),
                          content: Text('Do you want add marker?'),
                          actions: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        markers.add(Marker(
                                            markerId: MarkerId(
                                              '${argument.latitude}',
                                            ),
                                            position: LatLng(argument.latitude,
                                                argument.longitude),
                                            infoWindow: InfoWindow(
                                                title: "More info?",
                                                onTap: () async {
                                                  var res = await PlacesInfo
                                                      .getPlacesId(LatLng(
                                                          argument.latitude,
                                                          argument.longitude));
                                                  await Navigator.push(
                                                      (context),
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              GoogleMapScreen())));
                                                })));
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      child: Text('Add')),
                                ])
                          ],
                        ));
              }),
              markers: {
                Marker(
                    markerId: MarkerId("currentLocation"),
                    infoWindow: InfoWindow(title: "Its me"),
                    rotation: currentLocation!.heading!,
                    icon: currentIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                for (int i = 0; i < Set<Marker>.of(markers).length; i++)
                  Set<Marker>.of(markers).elementAt(i),
              },
              onCameraMove: ((position) {}),
              onMapCreated: (contoller) {
                googleMapController = contoller;
              },
            ),
          ),
      ])),
    );
  }
}
