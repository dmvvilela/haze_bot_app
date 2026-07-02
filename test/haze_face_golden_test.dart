import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';

// Renders the Haze V3 face in every expression/state to golden PNGs so the
// design can be reviewed visually. Regenerate with:
//   flutter test --update-goldens test/haze_face_golden_test.dart

const _faceKey = Key('face');

Widget _host(RobotFaceState state) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF17191D),
        body: Center(
          child: RepaintBoundary(
            key: _faceKey,
            child: SizedBox(
              width: 640,
              height: 768,
              child: HazeFace(state: state),
            ),
          ),
        ),
      ),
    );

// Advance in small frames so the pose spring settles naturally; stay under
// the first gaze saccade (t = 1.6s) to keep goldens deterministic.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 90));
  }
}

void main() {
  for (final expression in RobotExpression.values) {
    testWidgets('haze face — ${expression.name}', (tester) async {
      tester.view.physicalSize = const Size(900, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          RobotFaceState(
            config: RobotConfig(
              expression: expression,
              faceType: FaceType.hazeV3,
            ),
          ),
        ),
      );
      await _settle(tester);
      await expectLater(
        find.byKey(_faceKey),
        matchesGoldenFile('goldens/haze_${expression.name}.png'),
      );
    });
  }

  testWidgets('haze face — talking', (tester) async {
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        const RobotFaceState(
          config: RobotConfig(faceType: FaceType.hazeV3),
          isSpeaking: true,
        ),
      ),
    );
    await _settle(tester);
    await expectLater(
      find.byKey(_faceKey),
      matchesGoldenFile('goldens/haze_talking.png'),
    );
  });

  testWidgets('haze face — thinking', (tester) async {
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        const RobotFaceState(
          config: RobotConfig(faceType: FaceType.hazeV3),
          isLoadingAI: true,
        ),
      ),
    );
    await _settle(tester);
    await expectLater(
      find.byKey(_faceKey),
      matchesGoldenFile('goldens/haze_thinking.png'),
    );
  });
}
