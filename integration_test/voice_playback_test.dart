import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:haze_bot_app/services/robot_voice_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('English and Portuguese TTS can play through the voice engine', (
    tester,
  ) async {
    final tts = FlutterTts();
    final voice = RobotVoiceService();
    await tts.awaitSynthCompletion(true);
    try {
      for (final sample in [
        ('en-US', 'Hello! I am Haze.'),
        ('pt-BR', 'Olá! Eu sou o Haze.'),
      ]) {
        await tts.setLanguage(sample.$1);
        final file = File(
          '${Directory.systemTemp.path}/haze_test_${sample.$1}_${DateTime.now().microsecondsSinceEpoch}.caf',
        );
        try {
          expect(
            await tts
                .synthesizeToFile(sample.$2, file.path, true)
                .timeout(const Duration(seconds: 20)),
            1,
          );
          expect(await file.length(), greaterThan(44));
          expect(
            await voice
                .playWavFile(file.path, preset: VoicePreset.robot)
                .timeout(const Duration(seconds: 20)),
            isTrue,
          );
        } finally {
          if (await file.exists()) await file.delete();
        }
      }
    } finally {
      await tts.stop();
      await voice.dispose();
    }
  });

  testWidgets('stopping and replacing real audio settles every playback', (
    tester,
  ) async {
    final voice = RobotVoiceService();
    final data = await rootBundle.load(
      'assets/voices/haze/compact_wit/hello.wav',
    );
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    try {
      final first = voice.playWavBytes(bytes, preset: VoicePreset.natural);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await voice.stopPlayback();
      expect(await first.timeout(const Duration(seconds: 5)), isTrue);
      expect(voice.level.value, 0);

      final interrupted = voice.playWavBytes(
        bytes,
        preset: VoicePreset.natural,
      );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final replacement = voice.playWavBytes(bytes, preset: VoicePreset.robot);
      expect(await interrupted.timeout(const Duration(seconds: 5)), isTrue);
      expect(await replacement.timeout(const Duration(seconds: 20)), isTrue);
      expect(voice.level.value, 0);
    } finally {
      await voice.dispose();
    }
  });
}
