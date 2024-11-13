import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
class LocationProvider with ChangeNotifier {
  Position? currentPosition;
  LatLng? _selectedLocation;
  String? _address;
  static const styleId = 'osm-liberty';
  List<LatLng> _routePoints = [];
  static const apiKey =
      'bkoi_a37f1d2bbaf0705bd3b736e5349e18f8c92d882a1c1730314f097ac58279b253';
  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 120,
    );
    currentPosition =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    notifyListeners();
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    final url =
        "https://barikoi.xyz/v2/api/route/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?api_key=${apiKey}&geometries=geojson";
    print("start ${start.longitude}");
    print("start ${start.latitude}");
    print("end ${end.longitude}");
    print("end ${end.latitude}");
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        // Extract coordinates from GeoJSON LineString
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        final List<LatLng> routePoints = coordinates.map((coord) {
          return LatLng(
              coord[1], coord[0]); // GeoJSON format is [longitude, latitude]
        }).toList();

        
          _routePoints = routePoints;
          notifyListeners();
        
      } else {
        print("No route found.");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
    print(_routePoints);
  }
}
