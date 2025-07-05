import 'package:flutter/widgets.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("App in Foreground");
        // Reconnect sockets or resume tasks
        break;
      case AppLifecycleState.paused:
        print("App in Background");
        // Pause operations or release resources
        break;
      case AppLifecycleState.detached:
        print("App Terminated or detached");
        // Clean up or save data
        break;
      case AppLifecycleState.inactive:
        print("App is inactive");
        break;
      case AppLifecycleState.hidden:
        print("App is hidden ??");
        break;
      // TODO: Handle this case.
    }
  }
}
