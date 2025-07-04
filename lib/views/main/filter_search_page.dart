import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:real_estate/controllers/filter_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/option_container.dart';

class FilterSearchPage extends StatefulWidget {
  const FilterSearchPage({super.key});

  @override
  State<FilterSearchPage> createState() => _FilterSearchPageState();
}

class _FilterSearchPageState extends State<FilterSearchPage> {
  final FilterController filterController = Get.find<FilterController>();

  final List<String> cities = [
    "Afrin",
    "Aleppo",
    "Al-Bukamal",
    "Al-Hasakah",
    "Al-Mayadin",
    "Al-Qunaytirah",
    "Al-Rastan",
    "Al-Sabinah",
    "Al-Tabqah",
    "Al-Tall",
    "Ariha",
    "As-Suwayda",
    "Baniyas",
    "Daraa",
    "Damascus",
    "Deir ez-Zor",
    "Douma",
    "Hama",
    "Homs",
    "Idlib",
    "Jableh",
    "Khan Shaykhun",
    "Latakia",
    "Maarrat al-Nu'man",
    "Manbij",
    "Qamishli",
    "Raqqa",
    "Salamiyah",
    "Saraqib",
    "Tadmur (Palmyra)",
    "Tartus",
    "Tell Abyad",
    "Yabrud",
    "Zabadani",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (filterController.isInitialLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        filterController.init();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHegiht = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.category),
        title: const Text("Filters"),
      ),
      body: GetBuilder<FilterController>(
          init: filterController,
          id: "main",
          builder: (controller) {
            if (filterController.isInitialLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Property Listing"),
                    const SizedBox(height: 20),
                    forSaleRentWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Active Status"),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        GetBuilder<FilterController>(
                          init: filterController,
                          id: "isActive",
                          builder: (controller) => Expanded(
                            flex: 1,
                            child: OptionContainer(
                              label: "Available",
                              colorCondition: filterController.isActive,
                              onTap: () {
                                filterController.flipIsActive();
                              },
                            ),
                          ),
                        ),
                        GetBuilder<FilterController>(
                          init: filterController,
                          id: "isNotActive",
                          builder: (controller) => Expanded(
                            flex: 1,
                            child: OptionContainer(
                              label: "Not Available	",
                              colorCondition: filterController.isNotActive,
                              onTap: () {
                                filterController.flipIsNotActive();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Property Type"),
                    const SizedBox(height: 20),
                    propertyTypeOptions(),
                    const SizedBox(height: 20),
                    const Text("Price Range"),
                    const SizedBox(height: 20),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "priceRange",
                      builder: (controller) => RangeSlider(
                        values: filterController.priceRange,
                        onChanged: (range) {
                          filterController.changePriceRange(range);
                        },
                        min: 0,
                        max: 10000,
                        divisions: 10000, // <-- Add this
                        labels: RangeLabels(
                          filterController.priceRange.start.toStringAsFixed(0),
                          filterController.priceRange.end.toStringAsFixed(0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Area Range"),
                    const SizedBox(height: 20),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "areaRange",
                      builder: (controller) => RangeSlider(
                        values: filterController.areaRange,
                        onChanged: (range) {
                          filterController.changeAreaRange(range);
                        },
                        min: 0,
                        max: 1000,
                        divisions: 1000, // <-- Add this
                        labels: RangeLabels(
                          filterController.areaRange.start.toStringAsFixed(0),
                          filterController.areaRange.end.toStringAsFixed(0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Rooms Range"),
                    const SizedBox(height: 20),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "roomsRange",
                      builder: (controller) => RangeSlider(
                        values: filterController.roomsRange,
                        onChanged: (range) {
                          filterController.changeRoomsRange(range);
                        },
                        min: 0,
                        max: 10,
                        divisions: 10, // <-- Add this
                        labels: RangeLabels(
                          filterController.roomsRange.start.toStringAsFixed(0),
                          filterController.roomsRange.end.toStringAsFixed(0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Baths Range"),
                    const SizedBox(height: 20),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "bathsRange",
                      builder: (controller) => RangeSlider(
                        values: filterController.bathsRange,
                        onChanged: (range) {
                          filterController.changeBathsRange(range);
                        },
                        min: 0,
                        max: 10,
                        divisions: 10, // <-- Add this
                        labels: RangeLabels(
                          filterController.bathsRange.start.toStringAsFixed(0),
                          filterController.bathsRange.end.toStringAsFixed(0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("rating Range"),
                    const SizedBox(height: 20),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "ratingRange",
                      builder: (controller) => RangeSlider(
                        values: filterController.ratingRange,
                        onChanged: (range) {
                          filterController.changeRatingRange(range);
                        },
                        min: 0,
                        max: 5.0,
                        divisions: 10, // <-- Add this
                        labels: RangeLabels(
                          filterController.ratingRange.start.toStringAsFixed(1),
                          filterController.ratingRange.end.toStringAsFixed(1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //cities
                    MultiSelectDialogField(
                      items: cities
                          .map((city) => MultiSelectItem(city, city))
                          .toList(),
                      searchable: true,
                      initialValue: filterController.selectedCities,
                      listType: MultiSelectListType.CHIP,
                      title: const Text("Cities"),
                      selectedColor: primaryColor,
                      selectedItemsTextStyle:
                          const TextStyle(color: Colors.white),
                      buttonText: const Text("Select Cities"),
                      onConfirm: (results) {
                        print("Selected cities: $results");
                        filterController.setSelectedCities(results);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Order By"), const SizedBox(height: 20),

                    orderOptions(),
                    const SizedBox(height: 30),
                    GetBuilder<FilterController>(
                      init: filterController,
                      id: "saveButton",
                      builder: (controller) => MyButton(
                        title: filterController.isSaveLoading ? null : "Save",
                        onPressed: () async {
                          filterController.changeIsSaveLoading(true);
                          await filterController.save();
                          filterController.changeIsSaveLoading(false);
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Row forSaleRentWidget() {
    return Row(
      children: [
        GetBuilder<FilterController>(
          init: filterController,
          id: "isForRent",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "For Rent",
              colorCondition: filterController.isForRent,
              onTap: () {
                filterController.flipIsForRent();
              },
            ),
          ),
        ),
        GetBuilder<FilterController>(
          init: filterController,
          id: "isForSale",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "For Sale",
              colorCondition: filterController.isForSale,
              onTap: () {
                filterController.flipIsForSale();
              },
            ),
          ),
        ),
      ],
    );
  }

  Row orderOptions() {
    return Row(
      children: [
        GetBuilder<FilterController>(
          init: filterController,
          id: "orderByArea",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "By area",
              colorCondition: filterController.orderByArea,
              onTap: () {
                filterController.flipOrderByArea();
              },
            ),
          ),
        ),
        GetBuilder<FilterController>(
          init: filterController,
          id: "orderByPrice",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "By price",
              colorCondition: filterController.orderByPrice,
              onTap: () {
                filterController.flipOrderByPrice();
              },
            ),
          ),
        ),
        GetBuilder<FilterController>(
          init: filterController,
          id: "orderAsc",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              onTap: () {
                filterController.flipOrderAsc();
              },
              label: "Ascending",
              colorCondition: filterController.orderAsc,
            ),
          ),
        ),
      ],
    );
  }

  Row propertyTypeOptions() {
    return Row(
      children: [
        GetBuilder<FilterController>(
          init: filterController,
          id: "villa",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "Villa",
              colorCondition: filterController.villa,
              onTap: () {
                filterController.flipVilla();
              },
            ),
          ),
        ),
        GetBuilder<FilterController>(
          init: filterController,
          id: "flat",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              label: "Flat",
              colorCondition: filterController.flat,
              onTap: () {
                filterController.flipFlat();
              },
            ),
          ),
        ),
        GetBuilder<FilterController>(
          init: filterController,
          id: "house",
          builder: (controller) => Expanded(
            flex: 1,
            child: OptionContainer(
              onTap: () {
                filterController.flipHouse();
              },
              label: "House",
              colorCondition: filterController.house,
            ),
          ),
        ),
      ],
    );
  }
}
