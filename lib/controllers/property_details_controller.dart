import 'package:get/get.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/models/property_details.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';

class PropertyDetailsController extends GetxController {
  bool isLoading = true;
  PropertyDetails? propertyDetails;
  List<bool> isFavorite = List.generate(100005, (index) => false);
  Set<Property> isFavoriteSet = {};
  List<double> cardAnimationScale = List.generate(100005, (index) => 1.0);
  void changeCardScale(int index , int builderId, double newScale) {
    cardAnimationScale[index] = newScale;
    update([
      "isFavorite$builderId"
    ]);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['main']);
  }

  void flipIsFavorite({required int propertyId,}) {
    isFavorite[propertyId] = !isFavorite[propertyId];
    update(['isFavorite', "isFavorite$propertyId"]);
  }

  void addToFavorites() {
    Property toAdd = propertyDetails!.toProperty();
    if (isFavorite[propertyDetails!.id]) {
      if (!isFavoriteSet.contains(toAdd)) {
        isFavoriteSet.add(toAdd);
      }
    } else {
      if (!isFavoriteSet.contains(toAdd)) {
        isFavoriteSet.remove(toAdd);
      }
    }
  }

  void initFavorites(Property property) {
    isFavoriteSet.add(property);
    isFavorite[property.id!] = true;
  }

  @override
  void onClose() async {
    // TODO: implement onClose
    List<Property> toDelete = [];
    for (Property property in isFavoriteSet) {
      if (isFavorite[property.id!]) continue;
      toDelete.add(property);
    }
    for (Property property in toDelete) {
      await PropertiesApis.cancelFavorite(propertyId: property.id!);
      isFavoriteSet.remove(property);
    }
    super.onClose();
  }

  void clear() {
    isLoading = true;
    isFavorite = List.generate(100005, (index) => false);
    isFavoriteSet = {};
  }
}
