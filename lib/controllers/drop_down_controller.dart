import 'package:get/get.dart';

class DropDownController extends GetxController {
  List<String> genders = ['Male', 'Female'];
  // List<String> propertyType = ['house', 'flat', 'villa'];
  // String selectedPropertyType = 'house';
  String selectedGender = 'Male';
  String selectedCountry = 'SY 963';
  void changeSelectedGender({required String? gender}) {
    selectedGender = gender ?? 'Male';
    update(['gender']);
  }

  void changeSelectedCountry({required String country}) {
    selectedCountry = country;
    update(['country']);
  }
}
