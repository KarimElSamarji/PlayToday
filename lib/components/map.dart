import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:playtoday/screen/search_screen.dart';

class Mymap extends State<SearchSreen> {
  double long = 49.5;
  double lat = -0.09;
  LatLng point = LatLng(48.0061, 0.1996);
  var location = [];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onTap: (p) async {
          location = await Geocoder.local.findAddressesFromCoordinates(
              Coordinates(p.latitude, p.longitude));
          setState(() {
            point = p;
            print(p);
          });
          print("${location.first} - ${location.first.featureName}");
        },
        center: LatLng(48.0061, 0.1996),
        zoom: 7.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: [
          Marker(
              width: 100.0,
              height: 100.0,
              point: point,
              builder: (ctx) => Container(
                  child: const Icon(Icons.location_on, color: Colors.red)))
        ]),
      ],
    );
  }
}
