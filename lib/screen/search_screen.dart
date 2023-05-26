import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:playtoday/components/image_gallery.dart';
import 'package:playtoday/components/map.dart';
import 'package:playtoday/components/navigation_drawer.dart';
import 'package:http/http.dart' as http;

import 'matches_screen.dart';

final MapController _mapController = MapController();
const String _baseUrl = 'https://customsearch.googleapis.com/customsearch/v1?';
const engineID = 'a54f6470f99e44888';
const apiKey = "AIzaSyACTCfNez4iztHl0SZTnVg-LrJ3Fp2ZFlE";

String? selectedStade;
Address? _selectedAdress;
Object? jsonRespone;
List<String> links = [];

class SearchSreen extends StatefulWidget {
  @override
  _MapAppState createState() => _MapAppState();
}

void searchStadium(String url) async {
  final response = await http.get(Uri.parse(url));
  try {
    var json = jsonDecode(response.body);
    for (var item in json['items']) {
      links.add(item['link']);
    }
    for (var link in links) {
      print(link);
    }
  } catch (e) {
    print('Error parsing JSON: $e');
  }
}

class _MapAppState extends State<SearchSreen> {
  double long = 49.5;
  double lat = -0.09;
  LatLng point = LatLng(48.0061, 0.1996);
  var location = [];

  void moveToLocation(double latitude, double longitude) {
    print("this is the latitude: ${latitude}");
    _mapController.move(LatLng(latitude, longitude), 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Search Page"),
            titleTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            actions: [
              IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(point, moveToLocation),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          point = value;
                        });
                      }
                    });
                    ;
                  },
                  icon: const Icon(Icons.search))
            ]),
        drawer: MyNavigationDrawer(),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: FlutterMap(
                key: UniqueKey(),
                options: MapOptions(
                  onTap: (p) async {
                    location = await Geocoder.local
                        .findAddressesFromCoordinates(
                            Coordinates(p.latitude, p.longitude));
                    setState(() {
                      point = p;
                      print(p);
                    });
                    print("${location.first} - ${location.first.featureName}");
                  },
                  center: point,
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(markers: [
                    Marker(
                        width: 100.0,
                        height: 100.0,
                        point: point,
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.red))
                  ]),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  if (_selectedAdress != null && selectedStade != null) ...[
                    ListTile(
                      title: Text(
                        'Selected Stade: $selectedStade',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedAdress!.addressLine,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                    Text(_selectedAdress!.adminArea),
                                    Text(_selectedAdress!.featureName),
                                    Text(_selectedAdress!.subAdminArea),
                                  ]),
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 40.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const ui.Size(50.0, 50.0),
                                        backgroundColor: const Color.fromARGB(
                                            255, 5, 65, 168),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MatchesPage(
                                                  parameter: selectedStade
                                                      .toString()
                                                      .toUpperCase())),
                                        );
                                      },
                                      child: const Text(
                                        'Play',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ))),
                            ))
                      ],
                    ),
                    ImageGallery(links),
                  ],
                  if (selectedStade == null) ...[
                    const Center(
                      child: ListTile(
                        title: Text(
                          'Search a Stadium by clicking the loop icon on top right',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Image(
                      image: AssetImage('assets/homeEmpty.png'),
                      width: 300,
                      height: 300,
                    )
                  ]
                ],
              ),
            )
          ],
        ));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final LatLng initialLocation;
  final Function(double, double) onSelectedLocation;

  CustomSearchDelegate(this.initialLocation, this.onSelectedLocation);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final url = '$_baseUrl?&key=$apiKey&cx=$engineID&searchType=image&q=$query';
    return FutureBuilder<List<Address>>(
        future: Geocoder.local.findAddressesFromQuery(query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            links.clear();
            return const Center(child: CircularProgressIndicator());
          }
          final locations = snapshot.data!;
          if (locations.isEmpty) {
            return const Center(
                child: Text('No results found for the searched location'));
          }
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                title: Text(location.addressLine ?? ''),
                subtitle: Text(location.locality ?? ''),
                onTap: () {
                  searchStadium(url);
                  selectedStade = query.toUpperCase();
                  _selectedAdress = location;
                  final latLng = LatLng(location.coordinates.latitude,
                      location.coordinates.longitude);
                  Navigator.of(context).pop(latLng);
                  onSelectedLocation(location.coordinates.latitude,
                      location.coordinates.longitude);
                },
              );
            },
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}
