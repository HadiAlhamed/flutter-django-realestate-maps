import 'package:get/get.dart';
import 'package:real_estate/models/property.dart';

class MyPropertiesController extends GetxController {
  List<Property> myProperties = [];
  bool isLoading = false;
  List<double> cardAnimationScale = List.generate(100005, (index) => 1.0);
  void changeCardScale(int index, int builderId, double newScale) {
    cardAnimationScale[index] = newScale;
    update([
      'propertyCard$index',
    ]);
  }

  void add(Property property) {
    int index = myProperties.indexWhere((p) {
      return p.id! == property.id!;
    });
    index == -1 ? myProperties.add(property) : myProperties[index] = property;
    if (index >= 0) update(["propertyCard$index"]);
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    update(['main']);
  }

  void clear() {
    myProperties = [];
  }
}
