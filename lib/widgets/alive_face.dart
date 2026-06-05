import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';

class AliveFace extends StatefulWidget {
  final RobotFaceState state;

  const AliveFace({super.key, required this.state});

  @override
  State<AliveFace> createState() => _AliveFaceState();
}

class _AliveFaceState extends State<AliveFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life;

  @override
  void initState() {
    super.initState();
    _life = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Haze V2 face',
      child: AnimatedBuilder(
        animation: _life,
        builder: (context, _) {
          final t = _life.value * math.pi * 2;
          final expression = widget.state.config.expression;
          final energy = switch (expression) {
            RobotExpression.excited => 1.0,
            RobotExpression.surprised => 0.85,
            RobotExpression.love => 0.78,
            RobotExpression.happy => 0.62,
            RobotExpression.winking => 0.58,
            RobotExpression.confused => 0.48,
            RobotExpression.angry => 0.72,
            RobotExpression.sleepy => 0.24,
          };

          return Transform.translate(
            offset: Offset(0, math.sin(t) * (3 + energy * 3)),
            child: CustomPaint(
              painter: _AliveFacePainter(
                state: widget.state,
                time: t,
                energy: energy,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _AliveFacePainter extends CustomPainter {
  final RobotFaceState state;
  final double time;
  final double energy;

  _AliveFacePainter({
    required this.state,
    required this.time,
    required this.energy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final eyeColor = state.config.eyeColor;
    final mouthColor = state.config.mouthColor;
    final expression = state.config.expression;
    final center = Offset(size.width / 2, size.height / 2);
    final isDark = state.config.isDarkTheme;
    final active = state.isLoadingAI || state.isTimerRunning;
    final pressPulse = state.isPressed ? 1.0 : 0.0;
    final pulse = (math.sin(time * 1.4) + 1) / 2;
    final bodyLift = math.sin(time) * (2 + energy * 2);

    final chassisPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1D2430),
                const Color(0xFF0A0E16),
                const Color(0xFF162632),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFFEFF7FA),
                const Color(0xFFDDE7EA),
              ],
      ).createShader(Offset.zero & size);

    final shell = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, 8 + bodyLift),
        width: size.width * 0.76,
        height: size.height * 0.72,
      ),
      const Radius.circular(54),
    );

    _drawGlow(canvas, size, eyeColor, mouthColor, active, pulse, pressPulse);
    _drawAntenna(canvas, size, eyeColor, bodyLift, active, pulse);
    canvas.drawRRect(shell, chassisPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = eyeColor.withValues(alpha: isDark ? 0.35 : 0.22);
    canvas.drawRRect(shell.deflate(5), rimPaint);

    _drawFacePanel(canvas, size, eyeColor, isDark, bodyLift);
    _drawCheeks(canvas, size, mouthColor, pulse, bodyLift);
    _drawEyes(canvas, size, eyeColor, mouthColor, expression, bodyLift);
    _drawBrows(canvas, size, eyeColor, expression, bodyLift);
    _drawMouth(canvas, size, mouthColor, expression, bodyLift);
    _drawExpressionAccents(canvas, size, eyeColor, mouthColor, expression);
  }

  void _drawGlow(
    Canvas canvas,
    Size size,
    Color eyeColor,
    Color mouthColor,
    bool active,
    double pulse,
    double pressPulse,
  ) {
    final glowAlpha = active ? 0.28 + pulse * 0.18 : 0.11 + energy * 0.08;
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Color.lerp(
                eyeColor,
                mouthColor,
                0.45,
              )!.withValues(alpha: glowAlpha + pressPulse * 0.16),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width * (0.48 + pulse * 0.05),
            ),
          );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.54,
      glowPaint,
    );
  }

  void _drawAntenna(
    Canvas canvas,
    Size size,
    Color eyeColor,
    double bodyLift,
    bool active,
    double pulse,
  ) {
    final base = Offset(size.width / 2, size.height * 0.16 + bodyLift);
    final tip = Offset(
      size.width / 2 + math.sin(time * 1.7) * 7,
      size.height * 0.07 + math.sin(time * 2.1) * 2,
    );
    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = eyeColor.withValues(alpha: 0.72);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(size.width * 0.48, size.height * 0.1, tip.dx, tip.dy);
    canvas.drawPath(path, wirePaint);

    final dotPaint = Paint()
      ..color = eyeColor.withValues(alpha: active ? 0.95 : 0.58 + pulse * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(tip, active ? 7 + pulse * 2 : 6, dotPaint);
    canvas.drawCircle(
      tip,
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _drawFacePanel(
    Canvas canvas,
    Size size,
    Color eyeColor,
    bool isDark,
    double bodyLift,
  ) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.43 + bodyLift),
        width: size.width * 0.6,
        height: size.height * 0.34,
      ),
      const Radius.circular(38),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = (isDark ? const Color(0xFF05070A) : const Color(0xFFF8FCFF))
            .withValues(alpha: 0.78),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = eyeColor.withValues(alpha: 0.2),
    );
  }

  void _drawCheeks(
    Canvas canvas,
    Size size,
    Color mouthColor,
    double pulse,
    double bodyLift,
  ) {
    final cheekPaint = Paint()
      ..color = mouthColor.withValues(alpha: 0.18 + pulse * 0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.29, size.height * 0.51 + bodyLift),
        width: 34,
        height: 14,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.71, size.height * 0.51 + bodyLift),
        width: 34,
        height: 14,
      ),
      cheekPaint,
    );
  }

  void _drawEyes(
    Canvas canvas,
    Size size,
    Color eyeColor,
    Color mouthColor,
    RobotExpression expression,
    double bodyLift,
  ) {
    final blink = state.isBlinking ? 0.1 : 1.0;
    final pupilBob = Offset(math.sin(time * 1.3) * 4, math.cos(time * 1.1) * 3);
    final look = switch (expression) {
      RobotExpression.confused => Offset(math.sin(time * 2.2) * 8, -2),
      RobotExpression.angry => const Offset(0, -4),
      RobotExpression.sleepy => const Offset(0, 6),
      RobotExpression.surprised => const Offset(0, -1),
      RobotExpression.excited => Offset(math.sin(time * 4) * 5, -4),
      _ => pupilBob,
    };

    _drawEye(
      canvas,
      Offset(size.width * 0.38, size.height * 0.39 + bodyLift),
      eyeColor,
      mouthColor,
      expression,
      blink,
      look,
      isLeft: true,
    );
    _drawEye(
      canvas,
      Offset(size.width * 0.62, size.height * 0.39 + bodyLift),
      eyeColor,
      mouthColor,
      expression,
      blink,
      look,
      isLeft: false,
    );
  }

  void _drawEye(
    Canvas canvas,
    Offset center,
    Color eyeColor,
    Color mouthColor,
    RobotExpression expression,
    double blink,
    Offset look, {
    required bool isLeft,
  }) {
    final winkClosed = expression == RobotExpression.winking && isLeft;
    final sleepyScale = expression == RobotExpression.sleepy ? 0.48 : 1.0;
    final surprisedScale = expression == RobotExpression.surprised ? 1.22 : 1.0;
    final excitedScale = expression == RobotExpression.excited
        ? 1 + math.sin(time * 6) * 0.08
        : 1.0;
    final eyeHeight = 48 * blink * sleepyScale * excitedScale;
    final eyeWidth = 54 * surprisedScale;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: eyeWidth,
        height: winkClosed ? 6 : math.max(6, eyeHeight),
      ),
      const Radius.circular(24),
    );

    final eyePaint = Paint()
      ..color = eyeColor.withValues(alpha: winkClosed ? 0.75 : 0.94)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawRRect(rect, eyePaint);

    if (winkClosed || blink < 0.5) return;

    if (expression == RobotExpression.love) {
      _drawHeart(canvas, center + look * 0.5, 13, mouthColor);
      return;
    }

    final pupilSize = switch (expression) {
      RobotExpression.surprised => 17.0,
      RobotExpression.sleepy => 10.0,
      RobotExpression.angry => 12.0,
      RobotExpression.excited => 14.0,
      _ => 13.0,
    };
    final pupil = center + look;
    canvas.drawCircle(
      pupil,
      pupilSize,
      Paint()..color = const Color(0xFF05080D),
    );
    canvas.drawCircle(
      pupil.translate(-4, -4),
      pupilSize * 0.24,
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
  }

  void _drawBrows(
    Canvas canvas,
    Size size,
    Color eyeColor,
    RobotExpression expression,
    double bodyLift,
  ) {
    final y = size.height * 0.29 + bodyLift;
    final leftAngle = switch (expression) {
      RobotExpression.angry => -0.55,
      RobotExpression.confused => 0.35,
      RobotExpression.surprised => -0.2,
      RobotExpression.sleepy => 0.18,
      RobotExpression.winking => 0.42,
      _ => math.sin(time * 1.1) * 0.08,
    };
    final rightAngle = switch (expression) {
      RobotExpression.angry => 0.55,
      RobotExpression.confused => -0.35,
      RobotExpression.surprised => 0.2,
      RobotExpression.sleepy => -0.18,
      _ => -math.sin(time * 1.1) * 0.08,
    };
    _drawBrow(canvas, Offset(size.width * 0.38, y), leftAngle, eyeColor);
    _drawBrow(canvas, Offset(size.width * 0.62, y), rightAngle, eyeColor);
  }

  void _drawBrow(Canvas canvas, Offset center, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-21, 0), const Offset(21, 0), paint);
    canvas.restore();
  }

  void _drawMouth(
    Canvas canvas,
    Size size,
    Color mouthColor,
    RobotExpression expression,
    double bodyLift,
  ) {
    final center = Offset(size.width / 2, size.height * 0.6 + bodyLift);
    final paint = Paint()
      ..color = mouthColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final path = Path();

    switch (expression) {
      case RobotExpression.happy:
      case RobotExpression.love:
        path.moveTo(center.dx - 32, center.dy - 2);
        path.quadraticBezierTo(
          center.dx,
          center.dy + 28,
          center.dx + 32,
          center.dy - 2,
        );
        break;
      case RobotExpression.surprised:
        canvas.drawOval(
          Rect.fromCenter(center: center, width: 28, height: 38),
          paint,
        );
        return;
      case RobotExpression.sleepy:
        path.moveTo(center.dx - 24, center.dy + 4);
        path.quadraticBezierTo(
          center.dx,
          center.dy + 11,
          center.dx + 24,
          center.dy + 4,
        );
        break;
      case RobotExpression.excited:
        path.moveTo(center.dx - 36, center.dy - 2);
        path.cubicTo(
          center.dx - 18,
          center.dy + 34 + math.sin(time * 8) * 4,
          center.dx + 18,
          center.dy + 34 - math.sin(time * 8) * 4,
          center.dx + 36,
          center.dy - 2,
        );
        break;
      case RobotExpression.confused:
        path.moveTo(center.dx - 32, center.dy + 8);
        path.cubicTo(
          center.dx - 14,
          center.dy - 8,
          center.dx + 4,
          center.dy + 20,
          center.dx + 32,
          center.dy + 2,
        );
        break;
      case RobotExpression.angry:
        path.moveTo(center.dx - 30, center.dy + 16);
        path.quadraticBezierTo(
          center.dx,
          center.dy - 8,
          center.dx + 30,
          center.dy + 16,
        );
        break;
      case RobotExpression.winking:
        path.moveTo(center.dx - 32, center.dy);
        path.quadraticBezierTo(
          center.dx - 3,
          center.dy + 22,
          center.dx + 34,
          center.dy + 4,
        );
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawExpressionAccents(
    Canvas canvas,
    Size size,
    Color eyeColor,
    Color mouthColor,
    RobotExpression expression,
  ) {
    switch (expression) {
      case RobotExpression.sleepy:
        _drawSleepMarks(canvas, size, eyeColor);
        break;
      case RobotExpression.excited:
      case RobotExpression.surprised:
        _drawSignalMarks(canvas, size, eyeColor);
        break;
      case RobotExpression.love:
        _drawHeart(
          canvas,
          Offset(size.width * 0.78, size.height * 0.22),
          9,
          mouthColor.withValues(alpha: 0.9),
        );
        break;
      default:
        break;
    }
  }

  void _drawSleepMarks(Canvas canvas, Size size, Color color) {
    final painter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < 3; i++) {
      final rise = (time * 18 + i * 13) % 42;
      painter.text = TextSpan(
        text: 'z',
        style: TextStyle(
          color: color.withValues(alpha: 0.22 + i * 0.14),
          fontSize: 12 + i * 4,
          fontWeight: FontWeight.w800,
        ),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size.width * 0.72 + i * 12, size.height * 0.28 - rise),
      );
    }
  }

  void _drawSignalMarks(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.42)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + (i - 1.5) * 0.28;
      final start = Offset(
        size.width / 2 + math.cos(angle) * 84,
        size.height * 0.25 + math.sin(angle) * 32,
      );
      final end = Offset(
        size.width / 2 + math.cos(angle) * (98 + math.sin(time * 4 + i) * 3),
        size.height * 0.25 + math.sin(angle) * 42,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.55)
      ..cubicTo(
        center.dx - size * 1.35,
        center.dy - size * 0.28,
        center.dx - size * 0.72,
        center.dy - size * 1.1,
        center.dx,
        center.dy - size * 0.42,
      )
      ..cubicTo(
        center.dx + size * 0.72,
        center.dy - size * 1.1,
        center.dx + size * 1.35,
        center.dy - size * 0.28,
        center.dx,
        center.dy + size * 0.55,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _AliveFacePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.state.config != state.config ||
        oldDelegate.state.isBlinking != state.isBlinking ||
        oldDelegate.state.isPressed != state.isPressed ||
        oldDelegate.state.isLoadingAI != state.isLoadingAI ||
        oldDelegate.state.isTimerRunning != state.isTimerRunning;
  }
}
