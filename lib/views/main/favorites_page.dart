import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/main_controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_controller.dart';
import 'package:real_estate/controllers/properties_controllers/property_details_controller.dart';
import 'package:real_estate/models/properties/property.dart';
import 'package:real_estate/widgets/general_widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/general_widgets/my_floating_action_button.dart';
import 'package:real_estate/widgets/property_widgets/property_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();

  final PropertyDetailsController pdController =
      Get.find<PropertyDetailsController>();
  final PropertyController propertyController = Get.find<PropertyController>();
  late final List<Property> favoritesProperties;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    favoritesProperties = pdController.isFavoriteSet.toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    pdController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: favoritesProperties.isEmpty
            ? const Center(
                child: Text(
                  "You have no favorites yet",
                ),
              )
            : AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // Height to width ratio
                  ),
                  itemCount: favoritesProperties
                      .length, // For example, 10 items for each tab
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        horizontalOffset: 50.0,
                        child: ScaleAnimation(
                          scale: 0.6,
                          child: FadeInAnimation(
                            curve: Curves.bounceOut,
                            child: GetBuilder(
                              init: pdController,
                              id: "isFavorite${favoritesProperties[index].id}",
                              builder: (controller) {
                                return AnimatedScale(
                                  scale: pdController.cardAnimationScale[index],
                                  duration: const Duration(milliseconds: 150),
                                  child: PropertyCard(
                                    key:
                                        ValueKey(favoritesProperties[index].id),
                                    index: index,
                                    scaleController: pdController,
                                    favorite: pdController.isFavorite[
                                        favoritesProperties[index].id!],
                                    property: favoritesProperties[index],
                                    pdController: pdController,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: GetBuilder<BottomNavigationBarController>(
        init: bottomController,
        builder: (controller) {
          return MyBottomNavigationBar(
            bottomController: bottomController,
          );
        },
      ),
    );
  }
}
