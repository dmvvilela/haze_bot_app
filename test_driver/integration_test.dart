import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for the store-screenshot run. Each screenshot name is a
/// project-relative path (e.g. release/screenshots/ios/en-US/iphone69/01_hero)
/// and lands there as a PNG.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final path = name.endsWith('.png') ? name : '$name.png';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      return true;
    },
  );
}
