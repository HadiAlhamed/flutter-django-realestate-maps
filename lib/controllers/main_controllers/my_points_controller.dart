import 'package:get/get.dart';
import 'package:real_estate/services/auth_services/auth_apis.dart';
import 'package:real_estate/widgets/general_widgets/my_snackbar.dart';

class MyPointsController extends GetxController {
  int myPoints = 0;
  int chosenPayment = 0;
  bool hidePassword = true;
  void changeChosenPayment(int index) {
    if (index == chosenPayment) return;
    chosenPayment = index;
    update(['paymentMethods']);
  }

  void flipHidePassword(bool? value) {
    hidePassword = value ?? !hidePassword;
    update(['hidePassword']);
  }

  void changeMyPoints(int value) {
    myPoints = value;
    update(['points']);
  }

  Future<void> chargePoints({
    required String bankName,
    required String creditCardNumber,
    required String password,
    required String amount,
  }) async {
    final int result = await AuthApis.chargePoints(
      bankName: bankName,
      creditCardNumber: creditCardNumber,
      password: "1234",
      amount: amount,
    );
    if (result == -1) {
      Get.showSnackbar(
        MySnackbar(
            success: false,
            title: "Charge Points",
            message: "Failed to charge points, please try again later"),
      );
    } else {
      myPoints = result;
      update(['points']);
    }
  }
}
