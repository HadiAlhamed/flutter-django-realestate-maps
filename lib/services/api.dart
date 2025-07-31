import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_storage/get_storage.dart';

class Api {
  static String baseUrl = "http://10.0.2.2:9999";
  static String wsUrl = "ws://10.0.2.2:9998";
  static final GetStorage box = GetStorage();
  static Future<void> init() async {
    baseUrl = await getHttpBaseUrl();
    wsUrl = await getWebSocketBaseUrl();
  }

  static Future<bool> isRunningOnEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice == false;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice == false;
    }
    return false;
  }

  static Future<String> getWebSocketBaseUrl() async {
    bool isEmulator = await isRunningOnEmulator();

    if (isEmulator) {
      return 'ws://10.0.2.2:9998';
    } else {
      return 'ws://192.168.1.3:9998'; // ← Replace with your actual local IP
    }
  }

  static Future<String> getHttpBaseUrl() async {
    bool isEmulator = await isRunningOnEmulator();

    if (isEmulator) {
      return 'http://10.0.2.2:9999';
    } else {
      return 'http://192.168.1.3:9999'; // ← Replace with your actual local IP
    }
  }
}
