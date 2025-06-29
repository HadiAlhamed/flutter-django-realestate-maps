import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_snackbar.dart';
import 'package:http/http.dart' as http;

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  OpenStreetMapScreenState createState() => OpenStreetMapScreenState();
}

class OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  final MapController _mapController = MapController();
  final Location location = Location();
  final TextEditingController locationController = TextEditingController();
  bool isLoading = true;
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  final BottomNavigationBarController bottomController = Get.find<BottomNavigationBarController>();
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _decodePolyline(
      String
          encodedPolyline) //decode the polyline into a list of geographic coordinates (lat , long)
  {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints =
        polylinePoints.decodePolyline(encodedPolyline);
    setState(() {
      route = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  Future<void> _fetchRoute() async {
    if (currentLocation == null || destination == null) return;
    debugPrint("trying to fetch route..");
    final Uri url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline");
    try {
      final response = await http.get(url);
      debugPrint("got route response... ${response.statusCode}");
      final data = json.decode(response.body);
      debugPrint("got route response... $data");
      
      if (response.statusCode == 200) {
        final geometry = data['routes'][0]['geometry'];
        _decodePolyline(geometry);
      } else {
        errorMessage("failed to fetch route");
      }
    } catch (e) {
      errorMessage("Network Error : failed to fetch route : $e");
    }
  }
  bool isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
  void errorMessage(String message) {
    Get.showSnackbar(
      MySnackbar(
        success: false,
        title: "Error",
        message: message,
      ),
    );
  }

  Future<void> _fetchCoordinatesPoint(String location) async {
    final Uri url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    try {
      final response = await http.get(url);
      debugPrint("got location coordinates response... ${response.statusCode}");
      
      final data = json.decode(response.body);
      debugPrint("$data");

      if (response.statusCode == 200) {
        final double lat = double.parse(data[0]['lat']);
        final double lon = double.parse(data[0]['lon']);
        print("$lat $lon");
        setState(() {
          destination = LatLng(lat, lon);
          _mapController.move(destination!, 15);
        });
        //fetch route
      } else {
        errorMessage("Location not found , try another place");
      }
    } catch (e) {
      errorMessage("Network Error : failed to fetch location : $e");
    }
  }

  Future<void> _initializeLocation() async {
    if (!(await _checkRequestPermissions())) return;
    location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        //update later and use GetxController
        setState(() {
          currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
        });
      }
    });
  }

  Future<bool> _checkRequestPermissions() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return false;
    }
    //now we know that the gps is on
    //get permissions to access their location
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return false;
    }
    //we have permission
    return true;
  }

  Future<void> _getCurrentUserLocation() async {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 15);
    } else {
      Get.showSnackbar(
        MySnackbar(
            success: false,
            title: "My location",
            message:
                "Current location is not available , please try again later"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: Stack(
        children: [
          isLoading ? const Center(child : CircularProgressIndicator() ) : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation ??
                    const LatLng(36.291944444444, 33.513055555556),
                initialZoom: 2,
                minZoom: 0,
                maxZoom: 100,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                const CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin, color: Colors.white),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.heading,
                  ),
                ),
                if (destination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        height: 50,
                        width: 50,
                        point: destination!,
                        
                        child:
                            const Icon(Icons.location_pin, color: Colors.red,size : 50,),
                      ),
                    ],
                  ),
                if(route.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: route,
                      strokeWidth: 5,
                      color : Colors.red,

                    ),
                  ]),
              ]),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      
                      controller: locationController,
                      decoration: InputDecoration(
                        
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                        hintText: "Enter a location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
                    onPressed: () async{
                      final location = locationController.text.trim();
                      if (location.isEmpty) return;
                      await _fetchCoordinatesPoint(location);
                      _fetchRoute();

                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentUserLocation,
        // backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: MyBottomNavigationBar(bottomController: bottomController),
    );
  }
}
