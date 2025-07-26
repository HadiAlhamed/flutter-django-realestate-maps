import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/models/profile_info.dart';

class ProfileController extends GetxController {
  XFile? profilePhoto;
  ProfileInfo? currentUserInfo;
  bool isUpdateLoading = false;
  bool isInitialLoading = true;
  void changeIsInitialLoading(bool value) {
    isInitialLoading = value;
    update([
      "profilePhoto",
      'fullName',
    ]);
  }

  void changeIsUpdateLoading(bool value) {
    isUpdateLoading = value;
    update(['updateProfile']);
  }

  void changeProfilePhoto(XFile photo) {
    profilePhoto = photo;
    update(['profilePhoto']);
  }

  void changeCurrentUserInfo(ProfileInfo profileInfo) {
    currentUserInfo = profileInfo;
    //update what need to be updated...
    update(['fullName', 'profilePhoto']);
  }

  void clear() {
    isUpdateLoading = false;
  }
}
