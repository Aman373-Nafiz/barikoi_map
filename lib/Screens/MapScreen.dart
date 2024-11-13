import 'dart:convert';
import 'package:barikoi_map/Widgets/LocationpopUp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Provider/LocationProvider.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;
  String? _address;
  String? currAddress;
  static const styleId = 'osm-liberty';
  List<LatLng> _routePoints = [];
  static const apiKey =
      'bkoi_a37f1d2bbaf0705bd3b736e5349e18f8c92d882a1c1730314f097ac58279b253';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .requestLocationPermission();
    });
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    final url =
        "https://barikoi.xyz/v2/api/route/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?api_key=${apiKey}&geometries=geojson";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        final List<LatLng> routePoints = coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();

        setState(() {
          _routePoints = routePoints;
        });
      } else {
        print("No route found.");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
    print(_routePoints);
  }

  Future<void> _getAddressFromLatLng(var lat, var long) async {
    print(lat);
    print(long);
    final url =
        "https://barikoi.xyz/v2/api/search/reverse/geocode?api_key=${apiKey}&longitude=${long}&latitude=${lat}&district=true&post_code=true&country=true&sub_district=true&union=true&pauroshova=true&location_type=true&division=true&address=true&area=true&bangla=true";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      setState(() {
        _address = json['place']?['address'] ?? 'Address not found';
        print('Extracted address: $_address');
      });
      print(json['place']['address']);
    } else {
      print('response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.currentPosition == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  minZoom: 9,
                  maxZoom: 20,
                  initialCenter: LatLng(
                    locationProvider.currentPosition!.latitude,
                    locationProvider.currentPosition!.longitude,
                  ),
                  initialZoom: 12,
                  onTap: (tapPosition, latLng) async {
                    setState(() {
                      _selectedLocation = latLng;
                    });
                    await _getAddressFromLatLng(
                      latLng.latitude,
                      latLng.longitude,
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'BariKoi Map',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 60,
                          height: 60,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: Colors.red,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  // ignore: deprecated_member_use
                  if (locationProvider.currentPosition != null)
                    // ignore: deprecated_member_use
                    PopupMarkerLayerWidget(
                      options: PopupMarkerLayerOptions(
                        markers: [
                          Marker(
                            point: LatLng(
                              locationProvider.currentPosition!.latitude,
                              locationProvider.currentPosition!.longitude,
                            ),
                            width: 70,
                            height: 70,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                        selectedMarkerBuilder:
                            (BuildContext context, Marker marker) {
                          return LocationPopup(
                            title: "User's Current Address",
                          );
                        },
                      ),
                    )
                ],
              ),
              if (_address != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.white.withOpacity(0.9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _address!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            final userLocation = LatLng(
                              locationProvider.currentPosition!.latitude,
                              locationProvider.currentPosition!.longitude,
                            );
                            _getDirections(userLocation, _selectedLocation!);
                          },
                          child: Text("Get Directions"),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
