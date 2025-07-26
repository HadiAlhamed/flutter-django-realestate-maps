import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/properties_controllers/my_properties_controller.dart';
import 'package:real_estate/models/filter_options.dart';
import 'package:real_estate/models/properties/paginated_property.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/widgets/property_card.dart';

class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key});

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final MyPropertiesController myPController =
      Get.find<MyPropertiesController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myPController.myProperties.isEmpty) _fetchMyProperties();
    });
  }

  Future<void> _fetchMyProperties() async {
    myPController.clear();
    myPController.changeIsLoading(true);

    PaginatedProperty pProperty =
        PaginatedProperty(nextPageUrl: null, properties: []);
    do {
      pProperty = await PropertiesApis.getProperties(
        url: pProperty.nextPageUrl,
        filterOptions: FilterOptions(
          onlyMine: true,
          selectedCities: [],
        ),
      );
      for (var property in pProperty.properties) {
        print("adding this property to my properties");
        print(property);
        myPController.add(property);
      }
    } while (pProperty.nextPageUrl != null);
    myPController.changeIsLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: GetBuilder(
            init: myPController,
            id: "main",
            builder: (controller) {
              if (myPController.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (myPController.myProperties.isEmpty) {
                return const Center(
                  child: Text(
                    "You Have No Owned Properties Yet",
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.only(top: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Height to width ratio
                ),
                itemCount: myPController.myProperties.length,
                itemBuilder: (context, index) {
                  return GetBuilder<MyPropertiesController>(
                    init: myPController,
                    id: "propertyCard$index",
                    builder: (controller) {
                      return AnimatedScale(
                        scale: myPController.cardAnimationScale[index],
                        duration: const Duration(milliseconds: 150),
                        child: PropertyCard(
                          key: ValueKey(myPController.myProperties[index].id!),
                          index: index,
                          scaleController: myPController,
                          property: myPController.myProperties[index],
                          onTap: () {
                            Get.toNamed("/addPropertyPage", arguments: {
                              'isAdd': false,
                              'propertyId':
                                  myPController.myProperties[index].id!,
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }),
      ),
    );
  }
}
