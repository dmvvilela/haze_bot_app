import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';

void main() {
  testWidgets('Aurea surprise morphs one mouth at every blend', (tester) async {
    tester.view.physicalSize = const Size(960, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const key = Key('mouth-blends');
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: const Color(0xFF0A1018),
            child: Row(
              children: [
                for (final surprise in [0.0, .65, 1.0])
                  Expanded(
                    child: HazeFace(
                      state: const RobotFaceState(),
                      framed: false,
                      affect: AureaExpression(
                        sorrow: .25,
                        openness: .5,
                        surprise: surprise,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 90));
    }
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/aurea_mouth_blends.png'),
    );
  });
}
