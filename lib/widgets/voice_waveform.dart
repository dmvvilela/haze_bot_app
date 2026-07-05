import 'package:flutter/material.dart';

import '../services/robot_voice_service.dart';

/// Scrolling loudness bars for whatever Haze is hearing or saying, in the
/// style of a voice-memo scope. Listens straight to the service's level
/// notifier (which ticks ~30ms during activity) instead of bloc state, so the
/// rest of the screen doesn't rebuild at audio rate.
class VoiceWaveform extends StatelessWidget {
  final RobotVoiceService voice;
  final Color color;

  const VoiceWaveform({super.key, required this.voice, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: voice.level,
        builder: (context, _) => CustomPaint(
          painter: _WaveformPainter(
            levels: voice.levelHistory,
            color: color,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> levels;
  final Color color;

  _WaveformPainter({required this.levels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    final step = size.width / levels.length;
    final midY = size.height / 2;
    for (var i = 0; i < levels.length; i++) {
      // Newest samples on the right, fading toward the older left edge.
      final age = i / levels.length;
      paint.color = color.withValues(alpha: 0.15 + age * 0.75);
      final barHalf = 2 + levels[i].clamp(0.0, 1.0) * (midY - 3);
      final x = step * (i + 0.5);
      canvas.drawLine(Offset(x, midY - barHalf), Offset(x, midY + barHalf), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
