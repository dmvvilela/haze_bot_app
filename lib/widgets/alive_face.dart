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
    final isDark = state.config.isDarkTheme;
    final active = state.isLoadingAI || state.isTimerRunning;
    final pressPulse = state.isPressed ? 1.0 : 0.0;
    final pulse = (math.sin(time * 1.4) + 1) / 2;
    final bodyLift = math.sin(time) * (2 + energy * 2);

    _drawGlow(canvas, size, eyeColor, mouthColor, active, pulse, pressPulse);
    _drawShadow(canvas, size, bodyLift, isDark);
    _drawShell(canvas, size, eyeColor, isDark, bodyLift);
    _drawAntennaAndTufts(canvas, size, eyeColor, bodyLift, active, pulse);
    _drawDeviceDetails(canvas, size, eyeColor, isDark, pulse, bodyLift);
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

  void _drawShadow(Canvas canvas, Size size, double bodyLift, bool isDark) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.5,
        height: 24 - bodyLift.clamp(-6, 8),
      ),
      Paint()
        ..color = (isDark ? Colors.black : const Color(0xFF6C7880)).withValues(
          alpha: isDark ? 0.42 : 0.16,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawAntennaAndTufts(
    Canvas canvas,
    Size size,
    Color eyeColor,
    double bodyLift,
    bool active,
    double pulse,
  ) {
    final hairPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = eyeColor.withValues(alpha: 0.42);

    for (final tuft in [
      (x: 0.42, angle: -0.28, length: 18.0),
      (x: 0.48, angle: -0.08, length: 15.0),
      (x: 0.54, angle: 0.1, length: 15.0),
      (x: 0.6, angle: 0.32, length: 17.0),
    ]) {
      final base = Offset(size.width * tuft.x, size.height * 0.17 + bodyLift);
      canvas.drawLine(
        base,
        base.translate(math.sin(tuft.angle) * tuft.length, -tuft.length),
        hairPaint,
      );
    }

    final base = Offset(size.width * 0.5, size.height * 0.15 + bodyLift);
    final tip = Offset(
      size.width * 0.5 + math.sin(time * 1.7) * 7,
      size.height * 0.06 + math.sin(time * 2.1) * 2,
    );
    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = eyeColor.withValues(alpha: 0.62);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.09,
        tip.dx,
        tip.dy,
      );
    canvas.drawPath(path, wirePaint);

    canvas.drawCircle(
      tip,
      active ? 6 + pulse * 2 : 5.4,
      Paint()
        ..color = eyeColor.withValues(alpha: active ? 0.95 : 0.66)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      tip.translate(-1, -1),
      2.7,
      Paint()..color = Colors.white.withValues(alpha: 0.86),
    );
  }

  void _drawShell(
    Canvas canvas,
    Size size,
    Color eyeColor,
    bool isDark,
    double bodyLift,
  ) {
    final shell = _shellPath(size, bodyLift);
    final chassisPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF253142),
                const Color(0xFF080C13),
                const Color(0xFF132B38),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFFEAF6F8),
                const Color(0xFFD4E1E6),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(shell, chassisPaint);

    canvas.drawPath(
      shell.shift(const Offset(0, -2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = eyeColor.withValues(alpha: isDark ? 0.38 : 0.24),
    );
    canvas.drawPath(
      shell,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = Colors.white.withValues(alpha: isDark ? 0.035 : 0.26),
    );
  }

  Path _shellPath(Size size, double bodyLift) {
    final w = size.width;
    final h = size.height;
    final y = bodyLift + 12;
    return Path()
      ..moveTo(w * 0.35, h * 0.15 + y)
      ..cubicTo(
        w * 0.44,
        h * 0.11 + y,
        w * 0.6,
        h * 0.11 + y,
        w * 0.69,
        h * 0.15 + y,
      )
      ..cubicTo(
        w * 0.79,
        h * 0.19 + y,
        w * 0.82,
        h * 0.34 + y,
        w * 0.79,
        h * 0.54 + y,
      )
      ..cubicTo(
        w * 0.77,
        h * 0.75 + y,
        w * 0.66,
        h * 0.85 + y,
        w * 0.5,
        h * 0.86 + y,
      )
      ..cubicTo(
        w * 0.34,
        h * 0.85 + y,
        w * 0.23,
        h * 0.75 + y,
        w * 0.21,
        h * 0.54 + y,
      )
      ..cubicTo(
        w * 0.18,
        h * 0.34 + y,
        w * 0.25,
        h * 0.19 + y,
        w * 0.35,
        h * 0.15 + y,
      )
      ..close();
  }

  void _drawDeviceDetails(
    Canvas canvas,
    Size size,
    Color eyeColor,
    bool isDark,
    double pulse,
    double bodyLift,
  ) {
    final y = bodyLift + 12;
    final detailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = eyeColor.withValues(alpha: isDark ? 0.18 : 0.14);
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.78 + y),
      Offset(size.width * 0.66, size.height * 0.78 + y),
      detailPaint,
    );

    final screwPaint = Paint()
      ..color = eyeColor.withValues(alpha: 0.16 + pulse * 0.04);
    for (final x in [size.width * 0.31, size.width * 0.69]) {
      canvas.drawCircle(Offset(x, size.height * 0.7 + y), 3.2, screwPaint);
    }
  }

  void _drawFacePanel(
    Canvas canvas,
    Size size,
    Color eyeColor,
    bool isDark,
    double bodyLift,
  ) {
    final panelRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.4 + bodyLift),
      width: size.width * 0.62,
      height: size.height * 0.26,
    );
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(40));
    canvas.drawRRect(
      panel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF02060B).withValues(alpha: 0.42),
                  const Color(0xFF071827).withValues(alpha: 0.16),
                  const Color(0xFF071827).withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.34),
                  const Color(0xFFEAF9FF).withValues(alpha: 0.1),
                  const Color(0xFFEAF9FF).withValues(alpha: 0.02),
                ],
        ).createShader(panelRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
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
        center: Offset(size.width * 0.34, size.height * 0.51 + bodyLift),
        width: 28,
        height: 10,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.66, size.height * 0.51 + bodyLift),
        width: 28,
        height: 10,
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

    final lidHeight = switch (expression) {
      RobotExpression.sleepy => eyeHeight * 0.42,
      RobotExpression.angry => eyeHeight * 0.2,
      RobotExpression.confused => eyeHeight * 0.14,
      _ => eyeHeight * 0.08,
    };
    final lidPaint = Paint()
      ..color = const Color(
        0xFF02050A,
      ).withValues(alpha: expression == RobotExpression.sleepy ? 0.48 : 0.24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, rect.width, lidHeight),
        const Radius.circular(22),
      ),
      lidPaint,
    );

    canvas.drawArc(
      rect.outerRect.deflate(5),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.28),
    );

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
      pupilSize + 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Colors.white.withValues(alpha: 0.2 + energy * 0.12),
    );
    canvas.drawCircle(
      pupil,
      pupilSize + 3,
      Paint()..color = eyeColor.withValues(alpha: 0.2),
    );
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
    final y = size.height * 0.3 + bodyLift;
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
      ..color = color.withValues(alpha: 0.42)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-17, 0), const Offset(17, 0), paint);
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
