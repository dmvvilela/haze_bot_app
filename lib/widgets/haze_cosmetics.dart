import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/haze_look.dart';

/// Vector cosmetics share the face's transform, so they follow its gestures.
/// They never replace expression, eyelid, gaze, or speech animation.
class HazeCosmetics {
  static Path eye(HazeFaceStyle style, Rect rect, double radius, bool isLeft) {
    switch (style) {
      case HazeFaceStyle.classic:
        return Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      case HazeFaceStyle.orbit:
        return Path()..addOval(rect);
      case HazeFaceStyle.pixel:
        final x = rect.left, y = rect.top, w = rect.width, h = rect.height;
        final step = math.min(w, h) * .18;
        return Path()
          ..moveTo(x + step * 2, y)
          ..lineTo(x + w - step * 2, y)
          ..lineTo(x + w - step * 2, y + step)
          ..lineTo(x + w - step, y + step)
          ..lineTo(x + w - step, y + step * 2)
          ..lineTo(x + w, y + step * 2)
          ..lineTo(x + w, y + h - step * 2)
          ..lineTo(x + w - step, y + h - step * 2)
          ..lineTo(x + w - step, y + h - step)
          ..lineTo(x + w - step * 2, y + h - step)
          ..lineTo(x + w - step * 2, y + h)
          ..lineTo(x + step * 2, y + h)
          ..lineTo(x + step * 2, y + h - step)
          ..lineTo(x + step, y + h - step)
          ..lineTo(x + step, y + h - step * 2)
          ..lineTo(x, y + h - step * 2)
          ..lineTo(x, y + step * 2)
          ..lineTo(x + step, y + step * 2)
          ..lineTo(x + step, y + step)
          ..lineTo(x + step * 2, y + step)
          ..close();
      case HazeFaceStyle.aurora:
        final x = rect.center.dx, y = rect.center.dy;
        final w = rect.width / 2, h = rect.height / 2;
        final side = isLeft ? -1 : 1;
        return Path()
          ..moveTo(x + side * w, y - h)
          ..cubicTo(
            x - side * w * .7,
            y - h,
            x - side * w * 1.2,
            y - h * .1,
            x - side * w * .8,
            y + h * .55,
          )
          ..cubicTo(
            x - side * w * .2,
            y + h * 1.3,
            x + side * w,
            y + h,
            x + side * w,
            y + h * .1,
          )
          ..close();
    }
  }

  static void accessory(Canvas canvas, HazeAccessory accessory, Color color) {
    final gold = const Color(0xFFFFD28A);
    final ink = const Color(0xFF131B30);
    Paint stroke(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (accessory) {
      case HazeAccessory.none:
        return;
      case HazeAccessory.glasses:
        for (final x in [134.0, 266.0]) {
          final lens = Rect.fromCenter(
            center: Offset(x, 212),
            width: 112,
            height: 126,
          );
          canvas.drawOval(lens, stroke(ink, 10));
          canvas.drawOval(lens, stroke(gold, 4));
          canvas.drawArc(
            lens.deflate(8),
            -2.5,
            .5,
            false,
            stroke(Colors.white.withValues(alpha: .6), 2),
          );
        }
        final bridge = Path()
          ..moveTo(190, 209)
          ..quadraticBezierTo(200, 201, 210, 209);
        canvas.drawPath(bridge, stroke(ink, 10));
        canvas.drawPath(bridge, stroke(gold, 4));
        canvas.drawLine(
          const Offset(78, 205),
          const Offset(64, 199),
          stroke(gold, 4),
        );
        canvas.drawLine(
          const Offset(322, 205),
          const Offset(336, 199),
          stroke(gold, 4),
        );
      case HazeAccessory.crown:
        final crown = Path()
          ..moveTo(145, 145)
          ..lineTo(133, 108)
          ..lineTo(168, 123)
          ..lineTo(200, 92)
          ..lineTo(232, 123)
          ..lineTo(267, 108)
          ..lineTo(255, 145)
          ..close();
        canvas.drawPath(
          crown,
          Paint()
            ..shader = LinearGradient(
              colors: [gold, const Color(0xFFEBA64A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(const Rect.fromLTWH(130, 90, 140, 60)),
        );
        canvas.drawLine(
          const Offset(146, 150),
          const Offset(254, 150),
          stroke(gold, 5),
        );
        canvas.drawPath(star(const Offset(200, 127), 10), Paint()..color = ink);
        for (final p in [
          const Offset(133, 106),
          const Offset(200, 91),
          const Offset(267, 106),
        ]) {
          canvas.drawCircle(p, 4, Paint()..color = Colors.white);
        }
      case HazeAccessory.headphones:
        final arch = Path()
          ..moveTo(63, 215)
          ..cubicTo(45, 62, 355, 62, 337, 215);
        canvas.drawPath(arch, stroke(ink, 17));
        canvas.drawPath(arch, stroke(Color.lerp(color, Colors.white, .5)!, 7));
        for (final x in [62.0, 338.0]) {
          final cup = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, 221), width: 32, height: 76),
            const Radius.circular(13),
          );
          canvas.drawRRect(cup.inflate(4), Paint()..color = ink);
          canvas.drawRRect(
            cup,
            Paint()..color = Color.lerp(color, Colors.white, .45)!,
          );
          canvas.drawLine(Offset(x, 206), Offset(x, 234), stroke(ink, 4));
        }
      case HazeAccessory.comet:
        final trail = Path()
          ..moveTo(285, 119)
          ..quadraticBezierTo(315, 104, 338, 116);
        canvas.drawPath(trail, stroke(gold.withValues(alpha: .65), 3));
        canvas.drawPath(
          star(const Offset(316, 142), 22),
          Paint()..color = gold,
        );
        canvas.drawPath(star(const Offset(316, 142), 22), stroke(ink, 2));
        canvas.drawPath(
          star(const Offset(344, 119), 7),
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(const Offset(284, 144), 3, Paint()..color = gold);
    }
  }

  static Path star(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * .45;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }
}
