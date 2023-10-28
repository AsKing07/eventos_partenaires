import 'package:flutter/material.dart';
import 'package:flutter_open_street_map/open_street_map.dart';

class location extends StatefulWidget {
  const location({super.key});

  @override
  State<location> createState() => _locationState();
}

class _locationState extends State<location> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("LOCALISATION"),
      ),
      body: FlutterOpenStreetMap(
          buttonText: "Set Location",
          locationIconColor: Colors.blue,
          buttonforegroundColor: Colors.white,
          buttonTextStyle: TextStyle(fontSize: 20),
          center: LatLong(5, 10),
          onPicked: (pickedData) {
            print(pickedData.latLong.latitude);
            print(pickedData.latLong.longitude);
            print(pickedData.addressName);
            print(pickedData.address);
          }),
    );
  }
}
