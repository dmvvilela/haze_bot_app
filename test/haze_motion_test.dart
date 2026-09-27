import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';
import 'package:haze_bot_app/cubits/robot_face_cubit.dart';
import 'package:haze_bot_app/widgets/haze_face.dart';

void main() {
  testWidgets('Emotion changes stay smooth after a long session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 230);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const faceKey = Key('motion-face');
    final activation = ValueNotifier(0.0);
    addTearDown(activation.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: faceKey,
          child: ValueListenableBuilder<double>(
            valueListenable: activation,
            builder: (context, value, child) => HazeFace(
              framed: false,
              state: const RobotFaceState(lookTarget: Offset.zero),
              affect: AureaExpression(activation: value),
            ),
          ),
        ),
      ),
    );
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(minutes: 2));

    Future<Offset> eyeCenter() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(faceKey),
      );
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var count = 0;
        var xSum = 0.0;
        var ySum = 0.0;
        for (var y = 0; y < 160; y++) {
          for (var x = 0; x < image.width; x++) {
            final i = (y * image.width + x) * 4;
            // The solid cyan eyes, excluding glow and white highlights.
            if (data.getUint8(i) < 100 &&
                data.getUint8(i + 1) > 140 &&
                data.getUint8(i + 2) > 140) {
              count++;
              xSum += x;
              ySum += y;
            }
          }
        }
        image.dispose();
        expect(count, greaterThan(100));
        return Offset(xSum / count, ySum / count);
      }))!;
    }

    var previous = await eyeCenter();
    for (final target in [1.0, 0.0]) {
      activation.value = target;
      for (var frame = 0; frame < 35; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final current = await eyeCenter();
        expect(
          (current - previous).distance,
          lessThan(.5),
          reason:
              'The whole face must not jitter as emotion intensity changes.',
        );
        previous = current;
      }
    }
  });
}
