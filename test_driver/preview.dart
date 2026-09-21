import 'package:flutter_driver/driver_extension.dart';
import 'package:haze_bot_app/main.dart' as app;

/// Development-only entrypoint for live widget inspection and visual checks.
void main() {
  enableFlutterDriverExtension();
  app.main();
}
