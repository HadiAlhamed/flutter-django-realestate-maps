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
import 'package:real_estate/textstyles/text_colors.dart';
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
  LatLng? initialCenter;
  List<LatLng> route = [];
  List<LatLng> markers = [];
  LatLng? newPropertyMarker;
  List<LatLng> routeToNewProperty = [];
  late bool isNewProperty;
  final Map<String, dynamic> args = Get.arguments;
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();
  @override
  void initState() {
    super.initState();
    isNewProperty = args['isNewProperty'];
    initialCenter = args['initialCenter'];
    _initializeLocation();
  }

  void _decodePolyline(String encodedPolyline,
      {bool?
          newProperty}) //decode the polyline into a list of geographic coordinates (lat , long)
  {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints =
        polylinePoints.decodePolyline(encodedPolyline);
    if (mounted) {
      setState(() {
        route = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    }
  }

  Future<void> _fetchRouteFromTo(LatLng? from, LatLng? to) async {
    if (from == null || to == null) return;
    debugPrint("trying to fetch route From $from to $to..");
    final Uri url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=polyline");
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
        if (mounted) {
          setState(() {
            destination = LatLng(lat, lon);
            _mapController.move(destination!, 15);
          });
        }
        //fetch route
      } else {
        errorMessage("Location not found , try another place");
      }
    } catch (e) {
      debugPrint("Network Error : failed to fetch location : $e");
      errorMessage("Network Error : failed to fetch location : $e");
    }
  }

  Future<void> _initializeLocation() async {
    if (!(await _checkRequestPermissions())) return;
    location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        //update later and use GetxController
        if (mounted) {
          setState(() {
            currentLocation =
                LatLng(locationData.latitude!, locationData.longitude!);
            isLoading = false;
            _fetchRouteFromTo(currentLocation, initialCenter);
          });
        }
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter ??
                        currentLocation ??
                        const LatLng(36.291944444444, 33.513055555556),
                    initialZoom: 15,
                    minZoom: 0,
                    maxZoom: 100,
                    onTap: (tapPosition, point) {
                      print("point : $point");
                      if (mounted && isNewProperty) {
                        setState(() {
                          newPropertyMarker = point;
                        });
                      }
                    },
                  ),
                  children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      const CurrentLocationLayer(
                        style: LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            child:
                                Icon(Icons.location_pin, color: Colors.white),
                          ),
                          markerSize: Size(35, 35),
                          markerDirection: MarkerDirection.heading,
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          if (initialCenter != null)
                            Marker(
                              height: 50,
                              width: 50,
                              point: initialCenter!,
                              child: const Icon(
                                Icons.my_location_outlined,
                                color: Colors.blue,
                                size: 50,
                              ),
                            ),
                          if (destination != null)
                            Marker(
                              height: 50,
                              width: 50,
                              point: destination!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          if (newPropertyMarker != null)
                            Marker(
                              height: 50,
                              width: 50,
                              point: newPropertyMarker!,
                              child: const Icon(
                                Icons.house_sharp,
                                color: primaryColorInactive,
                                size: 50,
                              ),
                            ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          if (route.isNotEmpty)
                            Polyline(
                              points: route,
                              strokeWidth: 7,
                              borderColor:
                                  const Color.fromARGB(255, 172, 121, 117),
                              color: Colors.red,
                            ),
                        ],
                      ),
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
                    style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white),
                    onPressed: () async {
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNewProperty)
            FloatingActionButton(
              onPressed: () {
                if (newPropertyMarker == null) {
                  errorMessage(
                      'Place a marker on the map representing the property location');
                  return;
                }
                Get.back(result: newPropertyMarker);
              },
              // backgroundColor: Colors.blue,
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 40,
              ),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _fetchRouteFromTo(currentLocation, initialCenter);
            },
            // backgroundColor: Colors.blue,
            child: const Icon(
              Icons.route,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentUserLocation,
            // backgroundColor: Colors.blue,
            child: const Icon(
              Icons.my_location,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: isNewProperty || initialCenter != null
          ? null
          : MyBottomNavigationBar(bottomController: bottomController),
    );
  }
}
