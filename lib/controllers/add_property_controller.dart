import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyController extends GetxController {
  List<bool> facilitiesSelected = List.generate(6, (index) => false);
  List<XFile> imagesPicked = [];
  bool isForRent = true;
  String selectedType = '';
  String selectedCity = '';
  bool isAddLoading = false;
  void changeIsAddLoading(bool value) {
    isAddLoading = value;
    update(["addButton"]);
  }

  set setSelectedCity(String city) => selectedCity = city;
  set setSelectedType(String type) => selectedType = type;
  void flipSelectedAt(int index) {
    facilitiesSelected[index] = !facilitiesSelected[index];
    index < 3 ? update(['firstRow']) : update(['secondRow']);
  }

  bool getFacilitySelectedAt(int index) => facilitiesSelected[index];
  void changeIsForRent(value) {
    isForRent = value;
    update(['isForRent']);
  }

  void setImagesPicked(List<XFile> images) {
    clearImages();
    imagesPicked.addAll(images);
    update(['imagePicker']);
  }

  int get imagesLength => imagesPicked.length;

  List<XFile> get images => imagesPicked;
  List<bool> get facilities => facilitiesSelected;

  void clearImages() {
    imagesPicked.clear();
    update(['imagePicker']);
  }

  XFile getImageAt(int index) => imagesPicked[index];
  void clear() {
    facilitiesSelected = List.generate(6, (index) => false);
    imagesPicked = [];
    isForRent = true;
    selectedType = '';
    selectedCity = '';
  }
}
