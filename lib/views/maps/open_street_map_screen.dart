import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:real_estate/controllers/main_controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/main_controllers/my_map_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_controller.dart';
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
  final MyMapController myMapController = Get.find<MyMapController>();
  final TextEditingController locationController = TextEditingController();

  late bool isNewProperty;
  final Map<String, dynamic> args = Get.arguments;
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();
  final PropertyController propertyController = Get.find<PropertyController>();
  @override
  void dispose() {
    // TODO: implement dispose
    locationController.dispose();

    myMapController.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isNewProperty = args['isNewProperty'] ?? false;
    myMapController.initialCenter = args['initialCenter'];
    myMapController.setMarkers = propertyController.properties.map((property) {
      if (myMapController.initialCenter != null &&
          property.latitude! == myMapController.initialCenter!.latitude &&
          property.longitude! == myMapController.initialCenter!.longitude) {
        return Marker(
          height: 50,
          width: 50,
          point: myMapController.initialCenter!,
          key: ValueKey(property.id!),
          child: const Icon(
            Icons.my_location_outlined,
            color: Colors.blue,
            size: 50,
          ),
        );
      }
      return Marker(
        key: ValueKey(property.id),
        height: 50,
        width: 50,
        point: LatLng(property.latitude!, property.longitude!),
        child: IconButton(
          onLongPress: () {
            print("long pressing property..");

            _fetchRouteFromTo(myMapController.currentLocation,
                LatLng(property.latitude!, property.longitude!));
          },
          onPressed: () {
            Get.toNamed(
              '/propertyDetails',
              arguments: {
                'propertyId': property.id!,
                'mapReadOnly': true,
              },
            );
          },
          icon: Icon(
            Icons.location_on,
            color: primaryColor,
            size: 50,
          ),
        ),
      );
    }).toList();

    if (myMapController.destination != null) {
      myMapController.updateMarkers(
        key: ValueKey('destination'),
        newLocation: myMapController.destination!,
        oldLocation: null,
        color: Colors.red,
        icon: Icons.location_pin,
      );
    }
    if (myMapController.newPropertyLocation != null) {
      myMapController.updateMarkers(
        key: ValueKey('newPropertyLocation'),
        newLocation: myMapController.newPropertyLocation!,
        oldLocation: null,
        color: primaryColor,
        icon: Icons.add_location,
      );
    }
    _initializeLocation();
  }

  void _decodePolyline(
      String
          encodedPolyline) //decode the polyline into a list of geographic coordinates (lat , long)
  {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints =
        polylinePoints.decodePolyline(encodedPolyline);
    print("decoding route ...");
    myMapController.setRoute = decodedPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<void> _fetchRouteFromTo(LatLng? from, LatLng? to) async {
    if (!mounted) return;
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
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Aqari/1.0 (hadialhamed.py@gmail.com)', // required by Nominatim
        },
      );
      debugPrint("got location coordinates response... ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("$data");
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);
          print("$lat $lon");

          myMapController.updateMarkers(
            oldLocation: myMapController.destination,
            newLocation: LatLng(lat, lon),
            icon: Icons.location_pin,
            color: Colors.red,
            key: 'destination',
          );
          myMapController.setDestination = LatLng(lat, lon);
          _mapController.move(myMapController.destination!, 15);
        } else {
          errorMessage("Location not found , try another place");
        }
      } else {
        errorMessage("Location not found , try another place");
      }
    } catch (e) {
      debugPrint("Network Error : failed to fetch location : $e");
      errorMessage("Network Error : failed to fetch location : $e");
    }
  }

  Future<void> _initializeLocation() async {
    if (!(await _checkRequestPermissions())) {
      myMapController.changeIsMapLoading(false);

      return;
    }
    location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        //update later and use GetxController

        myMapController.currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        myMapController.changeIsMapLoading(false);
        _fetchRouteFromTo(
            myMapController.currentLocation, myMapController.initialCenter);
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
    if (myMapController.currentLocation != null) {
      _mapController.move(myMapController.currentLocation!, 15);
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
          GetBuilder<MyMapController>(
            init: myMapController,
            id: "isMapLoading",
            builder: (controller) => myMapController.isMapLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: myMapController.initialCenter ??
                          myMapController.currentLocation ??
                          const LatLng(36.291944444444, 33.513055555556),
                      initialZoom: 15,
                      minZoom: 0,
                      maxZoom: 100,
                      onTap: (tapPosition, point) {
                        print("!!!!!!!!!!!!point !!!!!!!!!!: $point");
                        if (isNewProperty) {
                          myMapController.updateMarkers(
                            oldLocation: myMapController.newPropertyLocation,
                            newLocation: point,
                            key: 'newPropertyLocation',
                          );
                          myMapController.setNewPropretyLocation = point;
                        } else if (myMapController.isFirstLocationSelected) {
                          myMapController.updateMarkers(
                            oldLocation: myMapController.firstLocation,
                            newLocation: point,
                            icon: Icons.edit_location_alt_outlined,
                            key: 'location1',
                          );
                          myMapController.setFirstLocation = point;
                        } else if (myMapController.isSecondLocationSelected) {
                          myMapController.updateMarkers(
                            oldLocation: myMapController.secondLocation,
                            newLocation: point,
                            icon: Icons.edit_location_alt,
                            key: 'location2',
                          );
                          myMapController.setSecondLocation = point;
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: "com.aqari.app",
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
                      GetBuilder<MyMapController>(
                        init: myMapController,
                        id: "markers",
                        builder: (controller) => MarkerLayer(
                          markers: myMapController.markers,
                        ),
                      ),
                      GetBuilder<MyMapController>(
                        init: myMapController,
                        id: "route",
                        builder: (controller) => PolylineLayer(
                          polylines: [
                            if (myMapController.route.isNotEmpty)
                              Polyline(
                                points: myMapController.route,
                                strokeWidth: 7,
                                borderColor:
                                    const Color.fromARGB(255, 172, 121, 117),
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
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
                      _fetchRouteFromTo(myMapController.currentLocation,
                          myMapController.destination);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: getFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          isNewProperty || myMapController.initialCenter != null
              ? null
              : MyBottomNavigationBar(bottomController: bottomController),
    );
  }

  Column getFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNewProperty)
          FloatingActionButton(
            onPressed: () {
              if (myMapController.newPropertyLocation == null) {
                errorMessage(
                    'Place a marker on the map representing the property location');
                return;
              }
              Get.back(result: myMapController.newPropertyLocation);
            },
            child: const Icon(
              Icons.check,
              color: primaryColor,
              size: 40,
            ),
          ),
        const SizedBox(height: 16),
        GetBuilder<MyMapController>(
          init: myMapController,
          id: 'firstLocationFAB',
          builder: (controller) => FloatingActionButton(
            backgroundColor:
                myMapController.isFirstLocationSelected ? Colors.green : null,
            elevation: myMapController.isFirstLocationSelected ? 4 : null,
            onPressed: () {
              if (myMapController.isSecondLocationSelected) {
                myMapController.changeSecondLocationSelected(null);
              }
              myMapController.changeFirstLocationSelected(null);
            },
            child: const Icon(Icons.edit_location_alt_outlined),
          ),
        ),
        const SizedBox(height: 16),
        GetBuilder<MyMapController>(
          init: myMapController,
          id: "secondLocationFAB",
          builder: (controller) => FloatingActionButton(
            backgroundColor:
                myMapController.isSecondLocationSelected ? Colors.green : null,
            elevation: myMapController.isSecondLocationSelected ? 4 : null,
            onPressed: () {
              if (myMapController.isFirstLocationSelected) {
                myMapController.changeFirstLocationSelected(null);
              }
              myMapController.changeSecondLocationSelected(null);
            },
            child: const Icon(Icons.edit_location_alt),
          ),
        ),
        const SizedBox(height: 16),
        GetBuilder<MyMapController>(
          init: myMapController,
          id: "fetchRouteFAB",
          builder: (controller) => FloatingActionButton(
            onPressed: () {
              bool isFirstNull = myMapController.firstLocation == null;
              bool isSecondNull = myMapController.secondLocation == null;
              myMapController.changeIsFetchingRoute(true);
              if (!isFirstNull && !isSecondNull) {
                _fetchRouteFromTo(myMapController.firstLocation,
                        myMapController.secondLocation)
                    .then(
                  (e) => myMapController.changeIsFetchingRoute(false),
                );
              } else if ((isFirstNull ^ isSecondNull) &&
                  myMapController.currentLocation != null) {
                _fetchRouteFromTo(
                  myMapController.currentLocation,
                  isFirstNull
                      ? myMapController.secondLocation
                      : myMapController.firstLocation,
                ).then(
                  (e) => myMapController.changeIsFetchingRoute(false),
                );
              } else if (myMapController.currentLocation != null &&
                  myMapController.destination != null) {
                _fetchRouteFromTo(
                  myMapController.currentLocation,
                  myMapController.destination,
                ).then(
                  (e) => myMapController.changeIsFetchingRoute(false),
                );
              }
            },
            child: const Icon(
              Icons.route,
            ),
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
    );
  }
}
