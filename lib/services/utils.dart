import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<XFile?> compressImage(File file) async {
  final originalExtension = path.extension(file.path); // e.g., .png, .jpg

  final dir = await getTemporaryDirectory();
  final targetPath = path.join(
      dir.path, "${DateTime.now().millisecondsSinceEpoch}$originalExtension");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70, // Try 60–80 for good balance
  );

  return result;
}
