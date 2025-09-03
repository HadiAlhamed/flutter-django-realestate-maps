import 'package:get/get.dart';
import 'package:real_estate/models/properties/property.dart';
import 'package:real_estate/models/properties/property_details.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';

class PropertyDetailsController extends GetxController {
  bool isLoading = true;
  PropertyDetails? propertyDetails;
  List<bool> isFavorite = List.generate(100005, (index) => false);
  Set<Property> isFavoriteSet = {};
  double newRating = 0.0;
  double averageRating = 0.0;
  bool wantToRate = false;

  List<double> cardAnimationScale = List.generate(100005, (index) => 1.0);
  void updateFavoriteProperty(int id,
      {double? newPrice, bool? isActive, double? newRating}) {
    for (Property property in isFavoriteSet) {
      if (property.id == id) {
        if (newPrice != null) property.price = newPrice;
        if (isActive != null) property.isActive = isActive;
        if (newRating != null) property.rating = newRating;
        print("✅ Property with id $id updated in favorties");
        update(["isFavorite$id"]);
        return;
      }
    }
    print("❌ Property with id $id not found in favorites");
  }

  void updateFlutterMap() {
    update(["flutterMap"]);
  }

  void changeNewRating(double value) {
    newRating = value;
    update(['rating']);
  }

  void changeAverageRating(double value) {
    averageRating = value;

    update(['averageRating', 'rating']);
  }

  void changeWantToRate(bool? value) {
    wantToRate = value ?? !wantToRate;
    update(['wantToRate', 'rating']);
  }

  void changeCardScale(int index, int builderId, double newScale) {
    cardAnimationScale[index] = newScale;
    update(["isFavorite$builderId"]);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['main']);
  }

  void flipIsFavorite({
    required int propertyId,
  }) {
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
