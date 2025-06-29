import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/filter_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/models/filter_options.dart';
import 'package:real_estate/models/paginated_property.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/widgets/property_card.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  bool isLoading = true;
  final PropertyController propertyController = Get.find<PropertyController>();
  List<Property> filteredProperties = [];
  Future<void> _fetchProperties() async {
    final FilterController filterController = Get.find<FilterController>();
    filterController.init();
    FilterOptions filterOptions = FilterOptions(
      isForRent: filterController.isForRent,
      isForSale: filterController.isForSale,
      flat: filterController.flat,
      villa: filterController.villa,
      house: filterController.house,
      minPrice: filterController.priceRange.start,
      maxPrice: filterController.priceRange.end,
      minArea: filterController.areaRange.start,
      maxArea: filterController.areaRange.end,
      minRooms: filterController.roomsRange.start.toInt(),
      maxRooms: filterController.roomsRange.end.toInt(),
      orderByArea: filterController.orderByArea,
      orderByPrice: filterController.orderByPrice,
      orderAsc: filterController.orderAsc,
      selectedCities: filterController.selectedCities,
    );
    PaginatedProperty pProperty =
        PaginatedProperty(nextPageUrl: null, properties: []);
    do {
      pProperty = await PropertiesApis.getProperties(
          url: pProperty.nextPageUrl, filterOptions: filterOptions);
      for (var property in pProperty.properties) {
        filteredProperties.add(property);
      }
    } while (pProperty.nextPageUrl != null);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                padding: const EdgeInsets.only(top: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Height to width ratio
                ),
                itemCount: filteredProperties
                    .length, // For example, 10 items for each tab
                itemBuilder: (context, index) {
                  return GetBuilder<PropertyController>(
                    init : propertyController,
                    id : "propertyCard$index",
                    builder:(controller)=> AnimatedScale(
                      scale: propertyController.cardAnimationScale[index],
                      duration: const Duration(milliseconds: 150),
                      child: PropertyCard(
                        index: index,
                        scaleController: propertyController,
                        property: Property(
                          area: filteredProperties[index].area,
                          city: filteredProperties[index].city,
                          isForRent: filteredProperties[index].isForRent,
                          numberOfRooms: filteredProperties[index].numberOfRooms,
                          price: filteredProperties[index].price,
                          propertyType: filteredProperties[index].propertyType,
                          address: filteredProperties[index].address,
                          id: filteredProperties[index].id,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
