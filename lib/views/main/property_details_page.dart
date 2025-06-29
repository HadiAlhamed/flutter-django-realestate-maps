import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/models/facility.dart';
import 'package:real_estate/models/property_details.dart';
import 'package:real_estate/models/property_image.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final PropertyDetailsController pdController =
      Get.find<PropertyDetailsController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPropertyDetails();
      _determinePosition();
    });
  }

  @override
  dispose() {
    pdController.addToFavorites();
    super.dispose();
  }

 

  Future<void> _fetchPropertyDetails() async {
    pdController.changeIsLoading(true);
    final args = Get.arguments as Map<String, dynamic>;
    final propertyId = args['propertyId'];
    final PropertyDetails? propertyDetails =
        await PropertiesApis.getPropertyDetails(
      propertyId: propertyId,
    );
    if (propertyDetails == null) {
      print("property details is null");
      return;
    }
    pdController.propertyDetails = propertyDetails;
    pdController.changeIsLoading(false);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Service Enabled : $serviceEnabled");
    if (!serviceEnabled) {
      // Location services are not enabled, do nothing or ask the user
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return;
    }
    print("trying to get current position ...");
    // Get current position
    Position position = await Geolocator.getCurrentPosition();
    print(position.latitude);
    print(position.longitude);

    _currentLocation = LatLng(position.latitude, position.longitude);

    _mapController.move(_currentLocation!, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    return Scaffold(
      body: GetBuilder<PropertyDetailsController>(
        init: pdController,
        id: 'main',
        builder: (controller) {
          if (pdController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    bottom:
                        90), // Prevent content from being hidden behind buttons
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: screenHeight * 0.3,
                          width: double.infinity,
                          decoration: const BoxDecoration(),
                          clipBehavior: Clip.antiAlias,
                          child: pdController.propertyDetails!.images.isEmpty
                              ? Image.asset(
                                  "assets/images/house.jpg",
                                  fit: BoxFit.cover,
                                )
                              : getImagePageView(),
                        ),
                        GetBuilder(
                          init: pdController,
                          id: "isFavorite",
                          builder: (controller) {
                            int propertyId = pdController.propertyDetails!.id;

                            return Positioned(
                              top: screenHeight * 0.22,
                              right: 4,
                              child: IconButton(
                                onPressed: () async {
                                  bool result = pdController
                                          .isFavorite[propertyId]
                                      ? await PropertiesApis.cancelFavorite(
                                          propertyId:
                                              pdController.propertyDetails!.id)
                                      : await PropertiesApis.addFavorite(
                                          propertyId:
                                              pdController.propertyDetails!.id);

                                  if (result) {
                                    pdController.flipIsFavorite(
                                        propertyId: propertyId);
                                  }
                                  Get.showSnackbar(
                                    MySnackbar(
                                      success: result,
                                      title: pdController.isFavorite[propertyId]
                                          ? "Adding to Favorties"
                                          : "Cancel Favorite",
                                      message: result
                                          ? "Property were ${pdController.isFavorite[propertyId] ? "added" : "cancelled"} successfully"
                                          : "An error has occurred, please try again later.",
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.favorite,
                                  color: pdController.isFavorite[propertyId]
                                      ? primaryColor
                                      : Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                      child: Text(
                        "${pdController.propertyDetails!.price.toString()} \$",
                      ),
                    ),
                    const Divider(),
                    roomsInfo(),
                    const Divider(),
                    propertyDetails(),
                    const SizedBox(height: 20),
                    getLocationTitle(),
                    getFlutterMap(),
                    const SizedBox(height: 5), // Extra space to avoid overlap
                  ],
                ),
              ),

              // Fixed Bottom Buttons (Like bottomNavigationBar)
              bookNow(),
            ],
          );
        },
      ),
    );
  }

  Widget bookNow() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      bottom: 0, // Distance from the bottom of the screen
      left: 0,
      right: 0,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyButton(
              title: 'Book Now',
              width: 0.8 * screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Padding getLocationTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0, left: 8, right: 8),
      child: Row(
        children: [
          Icon(Icons.gps_fixed),
          SizedBox(width: 10),
          Text(
            "Location",
          ),
        ],
      ),
    );
  }

  Container getFlutterMap() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.none, // Disables all interactions
          ),
          initialCenter: LatLng(35.1867283, 35.9517433),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(35.1867283, 35.9517433),
                child: Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding propertyDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Property Details",
          ),
          const SizedBox(height: 15),
          Text(
            "a ${pdController.propertyDetails!.area.toString()} squared meters ${pdController.propertyDetails!.propertyType} ${pdController.propertyDetails!.facilities.isEmpty ? "" : getFacilities()}.",
          ),
        ],
      ),
    );
  }

  Padding roomsInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
              "${pdController.propertyDetails!.propertyType} in ${pdController.propertyDetails!.city} ${pdController.propertyDetails!.details ?? ""}"),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              detailInfo(
                Icons.bed,
                "${pdController.propertyDetails!.numberOfRooms} beds",
              ),
              detailInfo(
                Icons.bathtub,
                "2 bath",
              ),
              detailInfo(
                Icons.aspect_ratio,
                "${pdController.propertyDetails!.area.toString()} Sqm",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row detailInfo(IconData iconData, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(iconData, color: primaryColor),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  String getFacilities() {
    String result = "with";
    int len = pdController.propertyDetails!.facilities.length;
    for (int i = 0; i < len; i++) {
      Facility? facility = pdController.propertyDetails!.facilities[i];
      if (i == 0) {
        result += " ${facility!.name}";
      } else if (i == len - 1)
        // ignore: curly_braces_in_flow_control_structures
        result += " and ${facility!.name}";
      else
        // ignore: curly_braces_in_flow_control_structures
        result += ', ${facility!.name}';
    }

    return result;
  }

  PageView getImagePageView() {
    List<PropertyImage?> images = pdController.propertyDetails!.images;
    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index]?.imageUrl ?? '',
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      },
    );
  }
}
