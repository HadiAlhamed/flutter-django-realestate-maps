import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputController extends GetxController {
  bool isTyping = false;
  ImagePicker imagepicker = ImagePicker();
  XFile? imageChosed;
  XFile? pdfChosed;
  void changeIsTyping(bool value) {
    isTyping = value;
    update(['isTyping']);
  }

  void changeImageChosed(XFile file) {
    imageChosed = file;
  }

  void changePdfChosed(XFile file) {
    pdfChosed = file;
  }
}
