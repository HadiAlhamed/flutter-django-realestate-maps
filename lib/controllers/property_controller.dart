import 'package:get/get.dart';
import 'package:real_estate/models/properties/facility.dart';
import 'package:real_estate/models/properties/property.dart';
import 'package:real_estate/models/properties/property_image.dart';

class PropertyController extends GetxController {
  List<Property> properties = [];
  List<Property> houses = [];
  List<Property> flats = [];
  List<Property> villas = [];
  bool isLoading = false;
  Map<int, List<PropertyImage>> propertyImages = {};
  Map<int, List<Facility>> propertyFacilities = {};
  List<Property> get getAll => properties;
  List<Property> get getHouses => houses;
  List<Property> get getVillas => villas;
  List<Property> get getFlats => flats;
  List<double> cardAnimationScale = List.generate(100005, (index) => 1.0);
  void changeCardScale(int index, int builderId, double newScale) {
    cardAnimationScale[index] = newScale;
    update([
      'propertyCard$index',
    ]);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['all', 'villa', 'house', 'flat']);
  }

  void addProperty(Property property) {
    int index = properties.indexWhere((p) {
      return p.id! == property.id!;
    });
    index == -1 ? properties.add(property) : properties[index] = property;
    if (property.propertyType!.toLowerCase() == 'house') {
      index = houses.indexWhere((p) {
        return p.id! == property.id!;
      });

      index == -1 ? houses.add(property) : houses[index] = property;

      update(['all', 'house']);
    } else if (property.propertyType!.toLowerCase() == 'flat') {
      index = flats.indexWhere((p) {
        return p.id! == property.id!;
      });

      index == -1 ? flats.add(property) : flats[index] = property;
      update(['all', 'flat']);
    } else {
      //villa
      index = villas.indexWhere((p) {
        return p.id! == property.id!;
      });

      index == -1 ? villas.add(property) : villas[index] = property;
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
