import 'package:get/get.dart';
import 'package:real_estate/models/facility.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/models/property_image.dart';

class PropertyController extends GetxController {
  List<Property> properties = [];
  List<Property> houses = [];
  List<Property> flats = [];
  List<Property> villas = [];
  List<Property> myProperties = [];
  bool isLoading = false;
  List<double> cardAnimationScale = List.generate(100005, (index) => 1.0);
  void changeCardScale(int index , int builderId, double newScale) {
    cardAnimationScale[index] = newScale;
    update(
      [
        'propertyCard$index',
        if(myProperties.length > index)"property${myProperties[builderId].id!}"
    ]);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['all', 'villa', 'house', 'flat']);
  }

  Map<int, List<PropertyImage>> propertyImages = {};
  Map<int, List<Facility>> propertyFacilities = {};
  List<Property> get getAll => properties;
  List<Property> get getHouses => houses;
  List<Property> get getVillas => villas;
  List<Property> get getFlats => flats;
  void addMyProperty(Property property) {
    for (int i = 0; i < myProperties.length; i++) {
      if (myProperties[i].id! == property.id!) {
        myProperties[i] = property;
        break;
      }
    }
    update(['property${property.id!}']);
  }

  void addProperty(Property property) {
    properties.add(property);
    if (property.propertyType.toLowerCase() == 'house') {
      houses.add(property);

      update(['all', 'house']);
    } else if (property.propertyType.toLowerCase() == 'flat') {
      flats.add(property);
      update(['all', 'flat']);
    } else {
      //villa
      villas.add(property);
      update(['all', 'villa']);
    }
  }

//XFile -> MultiPartFile -> FormData
  void addImageToProperty({
    required int propertyId,
    required PropertyImage image,
  }) {
    if (propertyImages[propertyId] == null) propertyImages[propertyId] = [];
    propertyImages[propertyId]?.add(image);
  }

  void addFacilityToProperty({
    required int propertyId,
    required Facility facility,
  }) {
    if (propertyFacilities[propertyId] == null) {
      propertyFacilities[propertyId] = [];
    }
    propertyFacilities[propertyId]?.add(facility);
  }

  void clearProperties() {
    properties.clear();
    houses.clear();
    villas.clear();
    flats.clear();
    // propertyImages.clear();
    // propertyFacilities.clear();
  }

  void clear() {
    properties.clear();
    propertyImages.clear();
    propertyFacilities.clear();
  }
}
