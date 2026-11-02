import 'dart:math' as math;

enum FaceActivity { resting, listening, thinking, speaking }

/// Small, additive gestures over Haze's mood. This never chooses an emotion.
/// Known silence is different from a platform voice with no audio meter.
class FacePerformance {
  FaceActivity activity = FaceActivity.resting;
  double _age = 0;
  double _finishAge = 10;
  double _emphasisCooldown = 0;
  double mouth = 0;
  double tilt = 0;
  double nod = 0;
  double attention = 0;
  double asymmetry = 0;
  double emphasis = 0;

  void advance({
    required double dt,
    required FaceActivity activity,
    double? level,
    bool reducedMotion = false,
  }) {
    if (!dt.isFinite || dt <= 0) return;
    dt = dt.clamp(0.0, .05);
    if (this.activity != activity) {
      _finishAge =
          this.activity == FaceActivity.speaking &&
              activity == FaceActivity.resting
          ? 0
          : 10;
      this.activity = activity;
      _age = 0;
      _emphasisCooldown = 0;
      emphasis = 0;
    }
    _age += dt;
    _finishAge += dt;
    _emphasisCooldown -= dt;
    final speaking = activity == FaceActivity.speaking;
    // A conservative fallback ONLY for unmetered system speech. A real zero
    // must never be replaced by invented syllables.
    final raw = !speaking
        ? 0.0
        : level == null
        ? .22 + .22 * math.pow(math.sin(_age * 9), 2)
        : level.isFinite
        ? level.clamp(0.0, 1.0)
        : 0.0;
    final target = raw < .025 ? 0.0 : ((raw - .025) / .975).clamp(0.0, 1.0);
    if (speaking && target > .55 && mouth < .35 && _emphasisCooldown <= 0) {
      emphasis = 1;
      _emphasisCooldown = .75;
    }
    mouth = _ease(mouth, target, dt, target > mouth ? 30 : 24);
    if (mouth < .008) mouth = 0;
    emphasis *= math.exp(-dt * 6);

    final listening = activity == FaceActivity.listening;
    final thinking = activity == FaceActivity.thinking;
    final finish = _finishAge < .8 ? math.sin(math.pi * _finishAge / .8) : 0.0;
    final entry = math.exp(-_age * 2.5);
    attention = _ease(attention, listening ? 1 : 0, dt, 7);
    asymmetry = _ease(
      asymmetry,
      thinking
          ? 1
          : listening
          ? .35
          : 0,
      dt,
      6,
    );
    tilt = _ease(
      tilt,
      thinking
          ? -.045
          : listening
          ? .035
          : 0,
      dt,
      6,
    );
    nod = _ease(
      nod,
      listening
          ? -1.8 * entry
          : speaking
          ? emphasis * 1.3
          : finish * 2,
      dt,
      12,
    );
    if (reducedMotion) {
      tilt = 0;
      nod = 0;
      emphasis = 0;
    }
  }

  static double _ease(double from, double to, double dt, double speed) =>
      from + (to - from) * (1 - math.exp(-dt * speed));
}
