import 'package:flutter/material.dart';
import '../models/robot_config.dart';

class MouthPainter extends CustomPainter {
  final RobotExpression expression;
  final Color color;
  final double animationValue;
  final bool isLooiStyle;
  final bool isMinimalStyle;
  final bool isBeanStyle;
  final bool isSpeaking;

  MouthPainter({
    required this.expression,
    required this.color,
    required this.animationValue,
    this.isLooiStyle = false,
    this.isMinimalStyle = false,
    this.isBeanStyle = false,
    this.isSpeaking = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = isMinimalStyle ? 4 : (isLooiStyle ? 5 : (isBeanStyle ? 4.5 : 6))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    if (isSpeaking) {
      _drawSpeakingMouth(canvas, size, paint, center);
      return;
    }

    switch (expression) {
      case RobotExpression.happy:
        _drawHappyMouth(canvas, size, paint, center);
        break;
      case RobotExpression.surprised:
        _drawSurprisedMouth(canvas, size, paint, center);
        break;
      case RobotExpression.sleepy:
        _drawSleepyMouth(canvas, size, paint, center);
        break;
      case RobotExpression.excited:
        _drawExcitedMouth(canvas, size, paint, center);
        break;
      case RobotExpression.confused:
        _drawConfusedMouth(canvas, size, paint, center);
        break;
      case RobotExpression.love:
        _drawLoveMouth(canvas, size, paint, center);
        break;
      case RobotExpression.angry:
        _drawAngryMouth(canvas, size, paint, center);
        break;
      case RobotExpression.winking:
        _drawWinkingMouth(canvas, size, paint, center);
        break;
    }
  }

  void _drawSpeakingMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    // Animated speaking mouth - oval that changes size
    paint.style = PaintingStyle.fill;
    final speakingScale = 0.8 + (animationValue * 0.4);
    canvas.drawOval(Rect.fromCenter(center: center, width: 25 * speakingScale, height: 35 * speakingScale), paint);
  }

  void _drawHappyMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    final width = isMinimalStyle ? 30 : (isLooiStyle ? 35 : (isBeanStyle ? 32 : 40));
    final height = isMinimalStyle ? 15 : (isLooiStyle ? 18 : (isBeanStyle ? 16 : 20));

    path.moveTo(center.dx - width, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + height, center.dx + width, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawSurprisedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    paint.style = PaintingStyle.fill;
    final width = isMinimalStyle ? 20.0 : (isLooiStyle ? 25.0 : 30.0);
    final height = isMinimalStyle ? 25.0 : (isLooiStyle ? 30.0 : 40.0);

    canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), paint);
  }

  void _drawSleepyMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final width = isMinimalStyle ? 15 : (isLooiStyle ? 18 : 20);
    canvas.drawLine(Offset(center.dx - width, center.dy), Offset(center.dx + width, center.dy), paint);
  }

  void _drawExcitedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    paint.style = PaintingStyle.fill;
    final path = Path();
    final width = isMinimalStyle ? 25 : (isLooiStyle ? 28 : 30);
    final height = isMinimalStyle ? 20 : (isLooiStyle ? 22 : 25);

    path.moveTo(center.dx - width, center.dy - height / 2);
    path.lineTo(center.dx + width, center.dy - height / 2);
    path.lineTo(center.dx + width * 0.7, center.dy + height / 2);
    path.lineTo(center.dx - width * 0.7, center.dy + height / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawConfusedMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    final width = isMinimalStyle ? 25 : (isLooiStyle ? 28 : 30);
    final amplitude = isMinimalStyle ? 8 : (isLooiStyle ? 10 : 10);

    path.moveTo(center.dx - width, center.dy - amplitude / 2);
    path.quadraticBezierTo(center.dx - width / 2, center.dy + amplitude, center.dx, center.dy - amplitude / 2);
    path.quadraticBezierTo(center.dx + width / 2, center.dy + amplitude, center.dx + width, center.dy - amplitude / 2);
    canvas.drawPath(path, paint);
  }

  void _drawLoveMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    paint.style = PaintingStyle.fill;

    // Draw heart shape
    final path = Path();
    final scale = isMinimalStyle ? 0.8 : (isLooiStyle ? 0.9 : 1.0);
    final heartSize = 15 * scale;

    path.moveTo(center.dx, center.dy + heartSize * 0.3);
    path.cubicTo(
      center.dx - heartSize * 0.5,
      center.dy - heartSize * 0.2,
      center.dx - heartSize,
      center.dy + heartSize * 0.3,
      center.dx,
      center.dy + heartSize * 0.8,
    );
    path.cubicTo(
      center.dx + heartSize,
      center.dy + heartSize * 0.3,
      center.dx + heartSize * 0.5,
      center.dy - heartSize * 0.2,
      center.dx,
      center.dy + heartSize * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawAngryMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    final width = isMinimalStyle ? 30 : (isLooiStyle ? 35 : 40);
    final height = isMinimalStyle ? 15 : (isLooiStyle ? 18 : 20);

    // Upside down smile (frown)
    path.moveTo(center.dx - width, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - height, center.dx + width, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawWinkingMouth(Canvas canvas, Size size, Paint paint, Offset center) {
    final path = Path();
    final width = isMinimalStyle ? 25 : (isLooiStyle ? 30 : 35);
    final height = isMinimalStyle ? 12 : (isLooiStyle ? 15 : 18);

    // Slight smile
    path.moveTo(center.dx - width, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + height, center.dx + width, center.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
