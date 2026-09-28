import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/services/robot_voice_service.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/i18n/strings.g.dart';

class _PlatformVoice extends RobotVoiceService {
  @override
  bool get isTtsCaptureSupported => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  late List<(String, String?)> spoken;
  String? selected;
  Completer<int>? pending;
  var holdSpeech = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    spoken = [];
    selected = null;
    pending = null;
    holdSpeech = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getVoices':
              return [
                {
                  'name': 'Samantha',
                  'locale': 'en-US',
                  'identifier': 'samantha',
                  'quality': 'enhanced',
                },
                {
                  'name': 'Luciana',
                  'locale': 'pt-BR',
                  'identifier': 'luciana',
                  'quality': 'enhanced',
                },
              ];
            case 'setLanguage':
              selected = null; // Matches the iOS plugin's behavior.
            case 'setVoice':
              selected = (call.arguments as Map)['identifier'] as String;
            case 'stop':
              if (pending != null && !pending!.isCompleted) {
                pending!.complete(1);
              }
            case 'speak':
              final arguments = call.arguments;
              final text = arguments is String
                  ? arguments
                  : (arguments as Map)['text'] as String;
              spoken.add((text, selected));
              if (holdSpeech) {
                pending = Completer<int>();
                return pending!.future;
              }
          }
          return 1;
        });
  });

  Future<void> until(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue);
  }

  test('speaking preview uses the selected voice on every utterance', () async {
    final robot = RobotFaceCubit(voice: _PlatformVoice());
    robot.sounds.enabled = false;
    addTearDown(robot.close);
    await robot.previewVoice(); // Works even with automatic speech disabled.
    await robot.previewVoice();
    expect(spoken.length, 2);
    expect(spoken.map((line) => line.$2), everyElement('samantha'));
    expect(spoken.first.$1, contains('I saved you a little spot'));
  });

  test('Portuguese preview uses Portuguese words and local voice', () async {
    final robot = RobotFaceCubit(voice: _PlatformVoice());
    robot.sounds.enabled = false;
    addTearDown(robot.close);
    await robot.previewVoice();
    robot.updateLanguage('pt-BR');
    await robot.previewVoice();
    expect(spoken.last.$1, startsWith('Ah! Você chegou.'));
    expect(spoken.last.$2, 'luciana');
  });

  test('Tiny Companion reactions use the conversation TTS voice', () async {
    final robot = RobotFaceCubit(voice: _PlatformVoice());
    robot.sounds.enabled = false;
    addTearDown(robot.close);
    await robot.previewVoice();
    robot.toggleSpeech();
    robot.updateExpression(RobotExpression.happy);
    await until(() => spoken.length == 2);
    expect(spoken.last.$1, t.expressions.happy);
    expect(spoken.last.$2, spoken.first.$2);
  });

  test(
    'an interrupted utterance cannot clear a newer speaking state',
    () async {
      final robot = RobotFaceCubit(voice: _PlatformVoice());
      robot.sounds.enabled = false;
      addTearDown(robot.close);
      holdSpeech = true;
      final first = robot.previewVoice();
      await until(() => spoken.length == 1);
      final second = robot.previewVoice();
      await until(() => spoken.length == 2);
      await first;
      expect(robot.state.isSpeaking, isTrue);
      pending!.complete(1);
      await second;
      expect(robot.state.isSpeaking, isFalse);
    },
  );
}
