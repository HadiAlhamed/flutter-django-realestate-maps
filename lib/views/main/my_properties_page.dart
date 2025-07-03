import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/widgets/property_card.dart';

class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key});

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final PropertyController propertyController = Get.find<PropertyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: propertyController.myProperties.isEmpty
            ? const Center(
                child: Text(
                  "You Have No Owned Properties Yet",
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.only(top: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Height to width ratio
                ),
                itemCount: propertyController.myProperties.length,
                itemBuilder: (context, index) {
                  return GetBuilder<PropertyController>(
                    init: propertyController,
                    id: "property${propertyController.myProperties[index].id!}",
                    builder: (controller) {
                      return AnimatedScale(
                        scale: propertyController.cardAnimationScale[index],
                        duration: const Duration(milliseconds: 150),
                        child: PropertyCard(
                          index: index,
                          scaleController: propertyController,
                          property: propertyController.myProperties[index],
                          onTap: () {
                            Get.toNamed("/addPropertyPage", arguments: {
                              'isAdd': false,
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
