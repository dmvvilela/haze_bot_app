import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';

void main() {
  testWidgets('speech retains warmth and concern and closes in pauses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(960, 460);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final voice = ValueNotifier(.8);
    final silence = ValueNotifier(0.0);
    addTearDown(voice.dispose);
    addTearDown(silence.dispose);
    const key = Key('speech-expressions');
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: const Color(0xFF080C12),
            child: Column(
              children: [
                for (final affect in [
                  const AureaExpression(warmth: .9, openness: .5),
                  const AureaExpression(sorrow: .8, warmth: .15, openness: .4),
                ])
                  Expanded(
                    child: Row(
                      children: [
                        for (final level in [null, voice, silence])
                          Expanded(
                            child: HazeFace(
                              framed: false,
                              state: RobotFaceState(
                                isSpeaking: level != null,
                                lookTarget: Offset.zero,
                              ),
                              affect: affect,
                              voiceLevel: level,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/haze_speech_expressions.png'),
    );
  });
}
