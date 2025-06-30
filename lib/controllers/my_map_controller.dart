import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class MyMapController extends GetxController {
  List<LatLng> route = [];
  List<Marker> markers = [];
  LatLng? newPropertyLocation;
  LatLng? destination;
  LatLng? currentLocation;
  LatLng? initialCenter;
  LatLng? firstLocation;
  LatLng? secondLocation;
  bool isMapLoading = true;
  bool isFirstLocationSelected = false;
  bool isSecondLocationSelected = false;
  bool isFetchingRoute = false;

  void changeFirstLocationSelected(bool? value) {
    isFirstLocationSelected = value ?? !isFirstLocationSelected;
    update(['firstLocationFAB']);
  }

  void changeSecondLocationSelected(bool? value) {
    isSecondLocationSelected = value ?? !isSecondLocationSelected;
    update(['secondLocationFAB']);
  }

  void changeIsMapLoading(bool value) {
    isMapLoading = value;
    update(['isMapLoading']);
  }

  set setCurrentLocation(LatLng location) {
    currentLocation = location;
    // update(['currentLocation']);
  }

  set setInitialCenter(LatLng location) {
    initialCenter = location;
    // update(['initialCenter']);
  }

  set setFirstLocation(LatLng location) {
    firstLocation = location;
    // update(['firstLocation']);
  }

  set setSecondLocation(LatLng location) {
    secondLocation = location;
    // update(["secondLocation"]);
  }

  set setNewPropretyLocation(LatLng location) {
    newPropertyLocation = location;
    // update(["newPropertyLocation"]);
  }

  set setDestination(LatLng location) {
    destination = location;
    // update(["destination"]);
  }

  set setRoute(List<LatLng> newRoute) {
    route = newRoute;
    update(["route"]);
  }

  set setMarkers(List<Marker> markers) {
    this.markers = markers;
    update(["markers"]);
  }

  void changeIsFetchingRoute(bool? value) {
    isFetchingRoute = value ?? !isFetchingRoute;
    update(['fetchRouteFAB']);
  }

  void updateMarkers({
    required LatLng? oldLocation,
    required LatLng newLocation,
    required dynamic key,
    IconData? icon,
    Color? color,
  }) {
    if (oldLocation != null) {
      for (int i = 0; i < markers.length; i++) {
        if (markers[i].point == oldLocation) {
          markers[i] = Marker(
            height: 50,
            width: 50,
            point: newLocation,
            key: ValueKey(key),
            child: Icon(
              icon ?? Icons.add_location,
              color: color ?? primaryColor,
              size: 50,
            ),
          );
          break;
        }
      }
    } else {
      markers.add(
        Marker(
          height: 50,
          width: 50,
          point: newLocation,
          child: Icon(
            icon ?? Icons.add_location,
            color: color ?? primaryColor,
            size: 50,
          ),
        ),
      );
    }
    update(['markers']);
  }

  void clear() {
    route = [];
    markers = [];
    newPropertyLocation = null;
    destination = null;
    isFirstLocationSelected = false;
    isSecondLocationSelected = false;
    isFetchingRoute = false;
    firstLocation = null;
    secondLocation = null;
    // dispose(); //check later if needed
  }
}
