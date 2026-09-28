import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:haze_bot_app/services/robot_voice_service.dart';
import 'package:haze_bot_app/services/tiny_companion_voice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'bundled speech is decoded and transformed by the playback path',
    () async {
      final data = await rootBundle.load(
        'assets/voices/haze/compact_wit/hello.wav',
      );
      final original = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final rendered = RobotVoiceService.renderCompanionWav(original);
      expect(identical(rendered, original), isFalse);
      expect(rendered, isNot(orderedEquals(original)));
      final header = ByteData.sublistView(rendered);
      expect(header.getUint16(22, Endian.little), 1);
      expect(header.getUint32(24, Endian.little), 24000);
      expect((rendered.length - 44) / 2 / 24000, closeTo(5.52, .01));
    },
  );

  test('raises pitch while preserving sentence duration and headroom', () {
    const rate = 24000;
    final input = Float64List.fromList(
      List.generate(
        rate * 2,
        (i) => .65 * math.sin(2 * math.pi * 440 * i / rate),
      ),
    );
    final output = TinyCompanionVoice.process(input, rate);
    expect(output.length, input.length);
    expect(
      output.every((sample) => sample.isFinite && sample.abs() <= .850001),
      isTrue,
    );
    double powerAt(double hz) {
      var re = 0.0;
      var im = 0.0;
      for (var i = rate ~/ 2; i < rate * 3 ~/ 2; i++) {
        final phase = 2 * math.pi * hz * i / rate;
        re += output[i] * math.cos(phase);
        im += output[i] * math.sin(phase);
      }
      return re * re + im * im;
    }

    final lifted = 440.0 * math.pow(2, 2.5 / 12);
    expect(powerAt(lifted), greaterThan(powerAt(440) * 10));
  });

  test('silence stays silent and short clips remain finite', () {
    expect(
      TinyCompanionVoice.process(Float64List(2400), 24000),
      everyElement(0),
    );
    expect(TinyCompanionVoice.process(Float64List(0), 24000), isEmpty);
    for (final rate in [8000, 22050, 24000, 48000]) {
      final output = TinyCompanionVoice.process(
        Float64List.fromList([.2, -.2, .1]),
        rate,
      );
      expect(output.length, 3);
      expect(output.every((sample) => sample.isFinite), isTrue);
    }
  });
}
