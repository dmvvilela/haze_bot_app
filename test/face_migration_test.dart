import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/models/robot_config.dart';

void main() {
  for (final oldStyle in [
    'classic',
    'looi',
    'minimal',
    'bean',
    'hazeV2',
    'hazeV3',
    'unknown',
  ]) {
    test(
      'saved $oldStyle settings retain customization without a face selector',
      () {
        final config = RobotConfig.fromJson({
          'faceType': oldStyle,
          'eyeColor': 0xff123456,
          'language': 'pt-BR',
          'speechRate': .7,
        });
        expect(config.eyeColor, const Color(0xff123456));
        expect(config.language, 'pt-BR');
        expect(config.speechRate, .7);
        expect(config.toJson().containsKey('faceType'), isFalse);
      },
    );
  }
}
