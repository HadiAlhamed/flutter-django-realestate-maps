import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate/controllers/chat_controllers/chat_controller.dart';
import 'package:real_estate/controllers/main_controllers/profile_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_details_controller.dart';
import 'package:real_estate/models/conversations/activate_chat_model.dart';
import 'package:real_estate/models/conversations/chat_status_check.dart';
import 'package:real_estate/models/conversations/conversation.dart';
import 'package:real_estate/models/properties/facility.dart';
import 'package:real_estate/models/properties/property_details.dart';
import 'package:real_estate/models/properties/property_image.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/chat_services/chat_apis.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/general_widgets/my_button.dart';
import 'package:real_estate/widgets/general_widgets/my_snackbar.dart';
import 'package:flutter_rating/flutter_rating.dart';

import '../../controllers/main_controllers/my_points_controller.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final MapController _mapController = MapController();
  final PropertyDetailsController pdController =
      Get.find<PropertyDetailsController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final MyPointsController myPointsController = Get.find<MyPointsController>();
  final ChatController chatController = Get.find<ChatController>();
  late final bool mapReadOnly;
  late final int propertyId;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    mapReadOnly = args['mapReadOnly'] ?? false;
    propertyId = args['propertyId'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchPropertyDetails();
      _determinePosition();
    });
  }

  @override
  dispose() {
    pdController.addToFavorites();
    pdController.changeAverageRating(0);
    pdController.changeWantToRate(false);
    pdController.changeNewRating(0);
    super.dispose();
  }

  Future<void> _fetchPropertyDetails() async {
    pdController.changeIsLoading(true);

    final PropertyDetails? propertyDetails =
        await PropertiesApis.getPropertyDetails(
      propertyId: propertyId,
    );
    if (propertyDetails == null) {
      print("property details is null");
      return;
    }
    pdController.propertyDetails = propertyDetails;

    pdController.changeNewRating(propertyDetails.rating ?? 0.0);
    pdController.changeAverageRating(propertyDetails.rating ?? 0.0);

    pdController.changeIsLoading(false);
  }

  Future<void> _determinePosition() async {
    _mapController.move(
        LatLng(pdController.propertyDetails!.latitude!,
            pdController.propertyDetails!.longitude!),
        15.0);
    pdController.updateFlutterMap();
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
                    const Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Ratings"),
                              const SizedBox(width: 4),
                              GetBuilder<PropertyDetailsController>(
                                init: pdController,
                                id: "rating",
                                builder: (controller) {
                                  return StarRating(
                                    allowHalfRating: false,
                                    color: primaryColor,
                                    starCount: 5,
                                    rating: pdController.wantToRate
                                        ? pdController.newRating
                                        : pdController.averageRating,
                                    size: 30,
                                    borderColor: primaryColorInactive,
                                    onRatingChanged: pdController.wantToRate
                                        ? (rating) {
                                            pdController
                                                .changeNewRating(rating);
                                          }
                                        : null,
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              GetBuilder<PropertyDetailsController>(
                                  init: pdController,
                                  id: "wantToRate",
                                  builder: (contorller) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (pdController.wantToRate) {
                                          //currently he pressed on save
                                          try {
                                            final newAvgRating =
                                                await PropertiesApis.editRating(
                                              propertyId: pdController
                                                  .propertyDetails!.id,
                                              rate: pdController.newRating
                                                  .toInt(),
                                            );
                                            print(
                                                "new avg rating : $newAvgRating");
                                            if (newAvgRating != -1) {
                                              pdController.changeAverageRating(
                                                  newAvgRating);
                                            } else {
                                              Get.showSnackbar(
                                                MySnackbar(
                                                    success: false,
                                                    title: "Rating Property",
                                                    message:
                                                        'You cannot rate a property more than once.'),
                                              );
                                            }
                                          } catch (e) {
                                            print(
                                                "new avg rating : error : $e");
                                          }
                                        }
                                        pdController.changeWantToRate(null);
                                      },
                                      child: Text(
                                        pdController.wantToRate
                                            ? 'Save'
                                            : '(Rate it)',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GetBuilder<PropertyDetailsController>(
                            init: pdController,
                            id: "averageRating",
                            builder: (controller) {
                              return Text(
                                "(current rate ${pdController.averageRating})",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

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
              onPressed: () async {
                if (Api.box.read("currentUserId") ==
                    pdController.propertyDetails!.owner) {
                  Get.snackbar(
                    'Booking Property',
                    "You Are The Owner Of This Property",
                  );
                  return;
                }
                final ChatStatusCheck? result =
                    await ChatApis.checkStatus(propertyId: propertyId);
                if (result == null) {
                  Get.snackbar("Booking Property",
                      "Failed to book property , please try again later");
                  return;
                }
                _handleBookingStatusCode(result);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBookingStatusCode(ChatStatusCheck result) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    String statusCode = result.statusCode;
    switch (statusCode) {
      case 'CHAT_ACTIVE':
        Get.toNamed("/chatPage", arguments: {
          'conversationId': result.conversationId,
        });
        break;
      case 'CHAT_EXPIRED_REACTIVATE':
        await _handleActivateReactivate(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          result: result,
          isExpired: true,
        );
        break;
      case 'NEW_CHAT_AVAILABLE':
        await _handleActivateReactivate(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          result: result,
          isExpired: false,
        );
        break;
      case 'INSUFFICIENT_POINTS':
        Get.snackbar(
          'Booking Property',
          'Your Current Aqari Points Are ${result.currentPoint} , you need a minimum of ${result.cost}.\nYou can buy aqari points via the Aqari Points page',
        );
        break;
      default:
        Get.snackbar("_handleBookingStatusCode", "unknown status code");
        break;
    }
  }

  Future<dynamic> _handleActivateReactivate({
    required bool isExpired,
    required double screenHeight,
    required double screenWidth,
    required ChatStatusCheck result,
  }) {
    return Get.dialog(
      barrierDismissible: true,
      Center(
        // Center the dialog manually
        child: Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 0.5 * screenHeight,
              maxWidth: 0.9 * screenWidth,
            ),
            padding: const EdgeInsets.all(18),
            color: Colors.white,
            // alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              "Starting a new booking chat for two months period with the owner of this property will cost you ",
                        ),
                        TextSpan(
                          text:
                              "${result.cost!.toStringAsFixed(2)} Aqari points",
                          style: TextStyle(
                            color: primaryColor, // Highlighted color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge, // Default style
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Text(
                          "Confirm",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: primaryColor),
                        ),
                        onPressed: () async {
                          final ActivateChatModel? activateChatModel =
                              await ChatApis.activateChat(
                            propertyId: propertyId,
                            conversationId: result.conversationId,
                            ownerId: pdController.propertyDetails!.owner!,
                          );
                          if (activateChatModel == null) {
                            Get.snackbar("Booking Property",
                                "Failed to book property , please try again later");
                            return;
                          }
                          if (isExpired) {
                            Get.back();

                            Get.snackbar("Booking property",
                                "Booking chat activated successfully , your new Aqari Points : ${activateChatModel.newPointsBalance}");
                            myPointsController.changeMyPoints(
                                activateChatModel.newPointsBalance);
                            profileController.currentUserInfo!.points =
                                activateChatModel.newPointsBalance.toInt();
                            Get.toNamed(
                              '/chatPage',
                              arguments: {
                                'conversationId': result.conversationId,
                              },
                            );
                          } else {
                            //new chat
                            Get.back();

                            Get.snackbar("Booking property",
                                "Booking chat activated successfully , your new Aqari Points : ${activateChatModel.newPointsBalance}");

                            myPointsController.changeMyPoints(
                                activateChatModel.newPointsBalance);
                            profileController.currentUserInfo!.points =
                                activateChatModel.newPointsBalance.toInt();
                            final Conversation? newConversation =
                                await ChatApis.getConversation(
                              conversationId: activateChatModel.conversationId!,
                            );
                            if (newConversation == null) {
                              Get.snackbar("New Conversation",
                                  "Failed to get new conversation");
                              return;
                            }
                            await chatController.add(newConversation);
                            Get.toNamed(
                              '/chatPage',
                              arguments: {
                                'conversationId': newConversation.id,
                              },
                            );
                          }
                        },
                      ),
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: primaryColorInactive),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
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

  GetBuilder<PropertyDetailsController> getFlutterMap() {
    return GetBuilder<PropertyDetailsController>(
      init: pdController,
      id: "flutterMap",
      builder: (contorller) => Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onTap: mapReadOnly
                ? null
                : (tapPosition, point) {
                    Get.toNamed('/openStreetMap', arguments: {
                      'isNewProperty': false,
                      'initialCenter': LatLng(
                          pdController.propertyDetails!.latitude!,
                          pdController.propertyDetails!.longitude!),
                    });
                  },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Disables all interactions
            ),
            initialCenter: pdController.propertyDetails?.latitude != null
                ? LatLng(pdController.propertyDetails!.latitude!,
                    pdController.propertyDetails!.longitude!)
                : const LatLng(35.1867283, 35.9517433),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.aqari.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(pdController.propertyDetails!.latitude!,
                      pdController.propertyDetails!.longitude!),
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
                "${pdController.propertyDetails!.bathrooms} bath",
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
