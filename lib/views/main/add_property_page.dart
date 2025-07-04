import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate/controllers/add_property_controller.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/drop_down_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/models/facility.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/models/property_image.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_button.dart';
import 'package:real_estate/widgets/my_floating_action_button.dart';
import 'package:real_estate/widgets/my_input_field.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();

  final TextEditingController roomController = TextEditingController();

  final TextEditingController bathController = TextEditingController();

  final TextEditingController areaController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final DropDownController dropDownController = Get.find<DropDownController>();

  final PropertyController propertyController = Get.find<PropertyController>();

  final AddPropertyController addProController =
      Get.find<AddPropertyController>();

  final ImagePicker imagePicker = ImagePicker();

  final List<String> propertyType = ['House', 'Flat', 'Villa'];
  final args = Get.arguments;
  late bool isAdd;
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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAdd = args['isAdd'];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    roomController.dispose();
    bathController.dispose();
    areaController.dispose();
    addressController.dispose();
    priceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text("${isAdd ? "Add" : "Update"} Property"),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isAdd) addImagesWidget(screenWidth, screenHeight),
                if (isAdd) const SizedBox(height: 20),
                getDropdownFormField(
                  hint: "Property Type",
                  onChanged: (value) {
                    if (value == null) return;
                    addProController.setSelectedType = value;
                  },
                  validatorHint: "Please choose your property type",
                  wantedList: propertyType,
                ),
                const SizedBox(
                  height: 20,
                ),
                getDropdownFormField(
                  hint: "City",
                  onChanged: (value) {
                    if (value == null) return;
                    addProController.setSelectedCity = value;
                  },
                  validatorHint:
                      "Please choose the city where this property is located",
                  wantedList: cities,
                ),
                const SizedBox(
                  height: 20,
                ),
                propertyInput(
                  ontap: () async {
                    final addressCoordinate =
                        await Get.toNamed('/openStreetMap', arguments: {
                      'isNewProperty': true,
                    });
                    print("address Coordinate : $addressCoordinate");
                    if (addressCoordinate != null) {
                      addProController.setNewPropertyCoord = addressCoordinate;
                      addressController.text =
                          "${addressCoordinate.latitude} , ${addressCoordinate.longitude}";
                    }
                  },
                  hint: 'Property Address',
                  readOnly: true,
                  controller: addressController,
                  suffixWidget: const Icon(Icons.place),
                ),
                propertyInput(
                  hint: 'Number of rooms',
                  controller: roomController,
                  keyboardType: TextInputType.number,
                  suffixWidget: const Icon(
                    Icons.bed,
                  ),
                ),
                propertyInput(
                  hint: 'Number of baths',
                  controller: bathController,
                  keyboardType: TextInputType.number,
                  suffixWidget: const Icon(
                    Icons.bathtub,
                  ),
                ),
                propertyInput(
                  hint: 'Total area by squared meter',
                  controller: areaController,
                  keyboardType: TextInputType.number,
                  suffixWidget: const Icon(
                    Icons.aspect_ratio,
                  ),
                ),
                propertyInput(
                  hint: 'Price',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  suffixWidget: const Icon(
                    Icons.attach_money,
                  ),
                ),
                Row(
                  children: [
                    const Text("For Rent"),
                    const SizedBox(width: 4),
                    GetBuilder<AddPropertyController>(
                      init: addProController,
                      id: "isForRent",
                      builder: (controller) => Radio<bool>(
                        value: true,
                        groupValue: addProController.isForRent,
                        onChanged: (value) {
                          if (value != null) {
                            addProController.changeIsForRent(value);
                          }
                        },
                      ),
                    ),
                    const Text("For Sale"),
                    const SizedBox(width: 4),
                    GetBuilder<AddPropertyController>(
                      init: addProController,
                      id: "isForRent",
                      builder: (controller) => Radio<bool>(
                        value: false,
                        groupValue: addProController.isForRent,
                        onChanged: (value) {
                          if (value != null) {
                            addProController.changeIsForRent(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (isAdd) getFacilitiesBox(screenHeight),
                const SizedBox(
                  height: 20,
                ),
                GetBuilder<AddPropertyController>(
                  init: addProController,
                  id: "addButton",
                  builder: (controller) => MyButton(
                    title: addProController.isAddLoading
                        ? null
                        : isAdd
                            ? "Add"
                            : "Update",
                    onPressed: isAdd ? handleAddProperty : handleUpdateProperty,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: MyBottomNavigationBar(
        bottomController: bottomController,
      ),
    );
  }

  void handleUpdateProperty() async {
    if (formKey.currentState!.validate()) {
      addProController.changeIsAddLoading(true);
      final Property? propertyResult = await PropertiesApis.updateProperty(
        property: Property(
          propertyType: addProController.selectedType.toLowerCase(),
          city: addProController.selectedCity,
          area: double.parse(areaController.text.trim()),
          price: double.parse(priceController.text.trim()),
          numberOfRooms: int.parse(roomController.text.trim()),
          isForRent: addProController.isForRent,
          bathrooms: int.parse(bathController.text.trim()),
        ),
      );
      addProController.changeIsAddLoading(false);
      bool flag = propertyResult != null;

      Get.showSnackbar(
        MySnackbar(
          success: flag,
          title: "Update Property",
          message: !flag
              ? "Failed to update property , please try again later"
              : "Property was updated successfully!",
        ),
      );
      if (flag) {
        propertyController.addMyProperty(propertyResult);
        addProController.clear();
        Get.offNamed('/myPropertiesPage');
      }
    }
  }

  void handleAddProperty() async {
    if (formKey.currentState!.validate()) {
      addProController.changeIsAddLoading(true);
      final Property? propertyResult = await PropertiesApis.addProperty(
        property: Property(
          propertyType: addProController.selectedType.trim().toLowerCase(),
          city: addProController.selectedCity,
          area: double.parse(areaController.text.trim()),
          price: double.parse(priceController.text.trim()),
          numberOfRooms: int.parse(roomController.text.trim()),
          isForRent: addProController.isForRent,
          latitude: addProController.newPropertyCoordinates.latitude,
          longitude: addProController.newPropertyCoordinates.longitude,
          bathrooms: int.parse(bathController.text.trim()),
        ),
      );
      addProController.changeIsAddLoading(false);
      bool flag = propertyResult != null;

      Get.showSnackbar(
        MySnackbar(
          success: flag,
          title: "Add Property",
          message: !flag
              ? "Failed to add property , please try again later"
              : "Property was added successfully!",
        ),
      );
      if (flag) {
        propertyController.addProperty(propertyResult);
        //add added images if any were added ,
        //add facilities added , if there were any.
        await Future.wait([
          handleAddImages(propertyResult),
          handleAddFacilities(propertyResult)
        ]);
        bottomController.changeSelectedIndex(
          index: 0,
        );
        addProController.clear();
        Get.offNamed('/home');
      }
    }
  }

  Future<void> handleAddFacilities(Property propertyResult) async {
    int facilitySuccess = 0;
    int isSelected = 0;
    for (int i = 0; i < 6; i++) {
      if (addProController.getFacilitySelectedAt(i)) {
        //add it
        isSelected++;
        final Facility? facility = await PropertiesApis.addFacilityToProperty(
          propertyId: propertyResult.id!,
          facilityId: (i + 1),
        );
        if (facility != null) {
          facilitySuccess++;
          propertyController.addFacilityToProperty(
            propertyId: propertyResult.id!,
            facility: facility,
          );
        }
      }
    }
    bool flag = facilitySuccess == isSelected;
    Get.showSnackbar(
      MySnackbar(
        success: flag,
        title: 'Adding Facilities',
        message: flag
            ? "Facilities were added successfully"
            : "Failed to add all facilities",
      ),
    );
  }

  Future<void> handleAddImages(Property propertyResult) async {
    if (addProController.imagesLength > 0) {
      int ImagesSuccess = 0;
      for (var imageFile in addProController.images) {
        final PropertyImage? propertyImage =
            await PropertiesApis.addImageToProperty(
                propertyId: propertyResult.id!, image: imageFile);
        if (propertyImage != null) {
          propertyController.addImageToProperty(
              propertyId: propertyResult.id!, image: propertyImage);
          ImagesSuccess++;
        }
      }
      bool allImagesAreAdded = ImagesSuccess == addProController.imagesLength;
      Get.showSnackbar(
        MySnackbar(
          success: allImagesAreAdded,
          title: "Adding Images",
          message: allImagesAreAdded
              ? "All images were added successfully"
              : "Some problem happened while uploading images",
        ),
      );
    }
  }

  Container getFacilitiesBox(double screenHeight) {
    return Container(
      height: 0.2 * screenHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 207, 205, 205),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Available Facilities :", style: h4TitleStyleBlack),
          GetBuilder<AddPropertyController>(
            id: 'firstRow',
            init: addProController,
            builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getFacility(index: 0, title: "Car Parking"),
                  const SizedBox(
                    width: 4,
                  ),
                  getFacility(index: 1, title: "Wi-Fi & Net"),
                  const SizedBox(
                    width: 4,
                  ),
                  getFacility(index: 2, title: "Laundry"),
                ],
              );
            },
          ),
          GetBuilder<AddPropertyController>(
            id: 'secondRow',
            init: addProController,
            builder: (controller) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getFacility(index: 3, title: "Gym & Fitness"),
                    const SizedBox(
                      width: 4,
                    ),
                    getFacility(index: 4, title: "Restaurants"),
                    const SizedBox(
                      width: 4,
                    ),
                    getFacility(index: 5, title: "Pool"),
                  ]);
            },
          ),
        ],
      ),
    );
  }

  InkWell getFacility({
    required int index,
    required String title,
  }) {
    return InkWell(
      onTap: () {
        addProController.flipSelectedAt(index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: addProController.facilitiesSelected[index]
              ? primaryColor
              : Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: h2TitleStyleWhite.copyWith(fontSize: 16)),
        ),
      ),
    );
  }

  Container getDropdownFormField(
      {required String hint,
      required String validatorHint,
      required List<String> wantedList,
      required void Function(String?)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: DropdownButtonFormField(
        hint: Text(hint),
        validator: (value) {
          if (!isAdd) return null;
          if (value == null || value == '') {
            return validatorHint;
          }
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: wantedList.map((element) {
          return DropdownMenuItem(value: element, child: Text(element));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  GetBuilder<AddPropertyController> addImagesWidget(
      double screenWidth, double screenHeight) {
    return GetBuilder<AddPropertyController>(
      init: addProController,
      id: 'imagePicker',
      builder: (controller) => Center(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 218, 218),
            borderRadius: BorderRadius.circular(10),
          ),
          width: 0.8 * screenWidth,
          height: 0.31 * screenHeight,
          child: addProController.imagesLength == 0
              ? initialImagePickerWidget(imagePicker)
              : selectedImageWidget(screenHeight, screenWidth),
        ),
      ),
    );
  }

  Padding selectedImageWidget(double screenHeight, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getRowImages(
            start: 0,
            end: 4,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          const SizedBox(
            height: 10,
          ),
          getRowImages(
            start: 4,
            end: 7,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          const SizedBox(
            height: 10,
          ),
          getRowImages(
            start: 7,
            end: 10,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          const SizedBox(
            height: 10,
          ),
          //add new images icon , clear chosen images icon
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              addNewImageIcon(imagePicker),
              IconButton(
                tooltip: "Delete all images selected",
                onPressed: () {
                  addProController.clearImages();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getRowImages({
    required int start,
    required int end,
    required double screenHeight,
    required double screenWidth,
  }) {
    List<Widget> images = [];
    for (int i = start; i < end; i++) {
      if (i >= addProController.imagesLength) break;
      images.add(
        Container(
          width: (0.7 * screenWidth) / (4.0),
          height: (0.25 * screenHeight) / 4.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            File(addProController.getImageAt(i).path),
            fit: BoxFit.cover,
            width: (0.7 * screenWidth) / (4.0),
            height: (0.25 * screenHeight) / 4.0,
            alignment: Alignment.center,
          ),
        ),
      );
      if (i != end - 1) {
        images.add(const SizedBox(
          width: 4,
        ));
      }
    }
    if (images.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: images,
    );
  }

  Column initialImagePickerWidget(ImagePicker imagePicker) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        addNewImageIcon(imagePicker),
        const SizedBox(
          height: 10,
        ),
        Text("Add Photos",
            style: h1TitleStyleBlack.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Max 10 images",
          style: h4TitleStyleBlack.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  InkWell addNewImageIcon(ImagePicker imagePicker) {
    return InkWell(
      onTap: () async {
        try {
          List<XFile?> newImagesPicked = await imagePicker.pickMultiImage(
            limit: 10,
          );
          List<XFile> imagesPicked = [];
          for (var image in newImagesPicked) {
            if (image == null) continue;
            imagesPicked.add(image);
          }
          if (imagesPicked.isNotEmpty) {
            addProController.setImagesPicked(imagesPicked);
          }
        } catch (e) {
          print("Error while loading images from image picker : $e");
        }
      },
      child: const CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(Icons.image_search, color: Colors.white),
      ),
    );
  }

  MyInputField propertyInput(
      {required String hint,
      Widget? suffixWidget,
      Widget? prefixWidget,
      required TextEditingController controller,
      bool? readOnly,
      void Function()? ontap,
      TextInputType? keyboardType}) {
    return MyInputField(
      keyboardType: keyboardType,
      prefixWidget: prefixWidget,
      ontap: ontap,
      readOnly: readOnly,
      controller: controller,
      suffixWidget: suffixWidget,
      hint: hint,
      borderSide: BorderSide.none,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
