import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../chemistry/chemistry.dart';
import '../aurea/aurea_model.dart';
import '../cubits/robot_face_cubit.dart';
import '../models/robot_config.dart';
import '../services/haze_mood.dart';

/// Haze V3 — the signature face.
///
/// Design language borrowed from commercial companion robots (Cozmo, EMO,
/// BellaBot): the screen IS the face. One dark panel, two big glowing eyes,
/// almost nothing else. Emotion lives in eyelid geometry — happy is a pair of
/// crescents, angry is a slanted lid, sleepy is a droop, love morphs the eye
/// into a heart. Every parameter is smoothed toward its per-expression target
/// each frame, so the face never snaps between states; blinks, breathing and
/// gaze saccades run on top to keep it alive while idle.
///
/// With a [mood] attached, the idle face stops being one of ten fixed poses:
/// whenever no explicit expression holds the screen, the target pose is a
/// live blend of the poses weighted by Haze's simulated neurochemistry — so
/// it can look mostly-content-but-a-little-anxious, states no single preset
/// can make.
class HazeFace extends StatefulWidget {
  final RobotFaceState state;

  /// Live loudness (0..1) of audio playing through the robot voice pipe.
  /// Null (e.g. in golden tests) falls back to the pseudo-syllable mouth.
  final ValueListenable<double>? voiceLevel;

  /// Haze's neurochemistry. Null (golden tests, previews) keeps the classic
  /// expression-driven behavior exactly as it was.
  final HazeMood? mood;

  /// A continuous performance from the Aurea experiment, independent of mood.
  final AureaExpression? affect;
  final bool framed;

  const HazeFace({
    super.key,
    required this.state,
    this.voiceLevel,
    this.mood,
    this.affect,
    this.framed = true,
  });

  @override
  State<HazeFace> createState() => _HazeFaceState();
}

class _HazeFaceState extends State<HazeFace>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final math.Random _random = math.Random();

  Duration _elapsed = Duration.zero;
  double _t = 0;

  late _FacePose _pose;
  double _blinkT = 1.0;
  Offset _gaze = Offset.zero;
  Offset _gazeTarget = Offset.zero;
  double _nextSaccadeAt = 1.6;
  // Small underdamped scale spring, kicked on every expression change.
  double _pop = 0;
  double _popVelocity = 0;

  @override
  void initState() {
    super.initState();
    _pose = _FacePose.of(widget.state.config.expression);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant HazeFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isBlinking && !oldWidget.state.isBlinking) {
      _blinkT = 0;
    }
    if (widget.state.config.expression != oldWidget.state.config.expression) {
      // The blink masks the morph between poses and the little scale bounce
      // sells the mood change.
      _blinkT = 0;
      _popVelocity += 2.4;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _elapsed).inMicroseconds / 1e6;
    _elapsed = elapsed;
    _t = elapsed.inMicroseconds / 1e6;
    if (dt <= 0) return;
    dt = math.min(dt, 0.05);

    final target =
        _affectTarget() ??
        _moodTarget() ??
        _FacePose.of(widget.state.config.expression);
    _pose = _FacePose.lerp(_pose, target, 1 - math.exp(-dt * 7.5));

    if (_blinkT < 1) _blinkT = math.min(1, _blinkT + dt / 0.30);

    final look = widget.state.lookTarget;
    if (look != null) {
      // A finger on the face wins over everything — the eyes track it.
      _gazeTarget = Offset(look.dx.clamp(-1.2, 1.2), look.dy.clamp(-1.0, 1.0));
    } else if (widget.state.isLoadingAI) {
      // Thinking: glance up and to the side, like recalling something.
      _gazeTarget = const Offset(0.45, -0.5);
    } else if (widget.state.isSpeaking) {
      _gazeTarget = const Offset(0, -0.08);
    } else if (_t >= _nextSaccadeAt) {
      _gazeTarget = _random.nextDouble() < 0.3
          ? Offset.zero
          : Offset(
              (_random.nextDouble() * 2 - 1) * (0.35 + target.wander * 0.45),
              (_random.nextDouble() * 2 - 1) * 0.22,
            );
      _nextSaccadeAt = _t + 1.1 + _random.nextDouble() * (2.6 - target.wander * 1.4);
    }
    // Track a finger snappily; wander lazily.
    _gaze = Offset.lerp(
      _gaze,
      _gazeTarget,
      1 - math.exp(-dt * (look != null ? 14 : 6.5)),
    )!;

    final springAccel = -_pop * 110 - _popVelocity * 10;
    _popVelocity += springAccel * dt;
    _pop += _popVelocity * dt;

    setState(() {});
  }

  double get _blinkClose {
    if (_blinkT >= 1) return 0;
    if (_blinkT < 0.38) return Curves.easeInQuad.transform(_blinkT / 0.38);
    return 1 - Curves.easeOutCubic.transform((_blinkT - 0.38) / 0.62);
  }

  _FacePose? _affectTarget() {
    final a = widget.affect;
    if (a == null) return null;
    final eye = _EyePose(
      open: .85 + a.openness * .24 + a.surprise * .2 - a.sorrow * .18,
      width: 1 - a.tension * .12,
      smile: a.warmth * .5,
      slant: -a.sorrow * .35 + a.tension * .2,
      round: .55 + a.openness * .3,
    );
    return _FacePose(
      left: eye,
      right: eye,
      mouthCurve: a.warmth * .8 - a.sorrow * .65 - a.tension * .2,
      mouthWide: .75 + a.warmth * .2,
      mouthOpen: a.openness * .15,
      mouthO: a.surprise * .4,
      blush: a.warmth * .65,
      tilt: a.sorrow * -.08 * (1 - a.steadiness),
      energy: .25 + a.activation * .6,
      wander: a.tension * (1 - a.steadiness) * .9,
      shiver: a.tension * (1 - a.steadiness * .85) * .7,
      gazeBias: Offset(a.approach * .12, a.sorrow * .15 - a.approach * .18),
    );
  }

  /// The pose Haze's chemistry is asking for, or null while an explicit
  /// expression (game round, easter egg, fresh brain reply) owns the face.
  _FacePose? _moodTarget() {
    final mood = widget.mood;
    if (mood == null || !mood.moodDriven) return null;
    final emotions = mood.emotions();

    // Only emotions clearly above the ambient hum get a say, and squaring
    // makes the strong ones dominate instead of everything averaging into
    // one mushy middle face.
    double sharp(Emotion emotion) {
      final x = (emotions[emotion] - 0.15).clamp(0.0, 1.0);
      return x * x;
    }

    // Euphoria has no pose of its own: it reads as thrilled + smitten.
    final euphoria = sharp(Emotion.euphoria);
    final base = _FacePose.blend([
      (_FacePose.of(RobotExpression.happy), sharp(Emotion.happiness)),
      (
        _FacePose.of(RobotExpression.excited),
        sharp(Emotion.excitement) + euphoria * 0.5,
      ),
      (
        _FacePose.of(RobotExpression.love),
        sharp(Emotion.bonding) + euphoria * 0.5,
      ),
      (_FacePose.of(RobotExpression.angry), sharp(Emotion.anger)),
      (_FacePose.of(RobotExpression.scared), sharp(Emotion.anxiety)),
      (_FacePose.of(RobotExpression.sad), sharp(Emotion.sadness)),
      // The calm anchor keeps a weak mix resting on a soft content face.
      (_FacePose.neutral, math.max(0.02, sharp(Emotion.calm))),
    ]);

    // All-or-nothing accents (heart eyes, "o" mouth, tears...) look ghostly
    // at partial blend weights — suppress them until their source pose
    // genuinely dominates the mix.
    double gate(double v) => v < 0.35 ? 0.0 : (v - 0.35) / 0.65;

    // Second projection, kindalive-style: chemicals also modulate the face
    // directly. Arousal sets the idle tempo, stress makes the gaze restless,
    // warmth blushes, and an extreme spike adds a trembling edge.
    final adrenaline = mood.level(Chemical.adrenaline);
    final dopamine = mood.level(Chemical.dopamine);
    final cortisol = mood.level(Chemical.cortisol);
    final oxytocin = mood.level(Chemical.oxytocin);

    _EyePose gateEye(_EyePose eye) => _EyePose(
          open: eye.open,
          width: eye.width,
          smile: eye.smile,
          droop: eye.droop,
          slant: eye.slant,
          round: eye.round,
          heart: gate(eye.heart),
          arc: gate(eye.arc),
        );

    return _FacePose(
      left: gateEye(base.left),
      right: gateEye(base.right),
      mouthCurve: base.mouthCurve,
      mouthOpen: base.mouthOpen,
      mouthWide: base.mouthWide,
      mouthO: gate(base.mouthO),
      mouthWave: gate(base.mouthWave),
      smirk: base.smirk,
      blush: (base.blush + (oxytocin - 0.2) * 0.5).clamp(0.0, 1.0),
      tilt: base.tilt,
      energy: (base.energy * (0.6 + adrenaline * 0.9 + (dopamine - 0.3) * 0.5))
          .clamp(0.15, 1.2),
      wander: (base.wander + (cortisol - 0.2) * 0.8).clamp(0.0, 1.0),
      sparkle: base.sparkle,
      zzz: gate(base.zzz),
      hearts: base.hearts,
      tear: gate(base.tear),
      shiver: (base.shiver + (adrenaline + cortisol - 1.2).clamp(0.0, 1.0))
          .clamp(0.0, 1.0),
      gazeBias: base.gazeBias,
    );
  }

  @override
  Widget build(BuildContext context) {
    final close = _blinkClose;
    // The ticker rebuilds every frame, so reading the current loudness here
    // keeps the mouth in sync with the real sound without extra plumbing.
    final voiceLevel = widget.voiceLevel?.value ?? 0;
    return Semantics(
      label: 'Haze face',
      child: CustomPaint(
        painter: _HazeFacePainter(
          pose: _pose,
          framed: widget.framed,
          t: _t,
          blinkMul: 1 - close * 0.97,
          blinkStretch: 1 + close * 0.07,
          pop: _pop,
          gaze: _gaze + _pose.gazeBias,
          eyeColor: widget.state.config.eyeColor,
          mouthColor: widget.state.config.mouthColor,
          isDark: widget.state.config.isDarkTheme,
          speaking: widget.state.isSpeaking,
          thinking: widget.state.isLoadingAI,
          voiceLevel: voiceLevel,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Per-eye shape parameters. All 0..1 unless noted; every value lerps.
class _EyePose {
  final double open; // height multiplier
  final double width; // width multiplier
  final double smile; // bottom lid rises into a happy crescent
  final double droop; // top lid falls straight down (sleepy)
  // Diagonal top lid cut: positive = lower at the inner corner (angry),
  // negative = lower at the outer corner (sad puppy eyes).
  final double slant;
  final double round; // 0 = soft rect, 1 = capsule/circle
  final double heart; // morph into a heart
  final double arc; // morph into a closed happy arc (wink)

  const _EyePose({
    this.open = 1,
    this.width = 1,
    this.smile = 0,
    this.droop = 0,
    this.slant = 0,
    this.round = 0.55,
    this.heart = 0,
    this.arc = 0,
  });

  static _EyePose blend(List<(_EyePose, double)> parts, double total) =>
      _EyePose(
        open: _sum(parts, total, (e) => e.open),
        width: _sum(parts, total, (e) => e.width),
        smile: _sum(parts, total, (e) => e.smile),
        droop: _sum(parts, total, (e) => e.droop),
        slant: _sum(parts, total, (e) => e.slant),
        round: _sum(parts, total, (e) => e.round),
        heart: _sum(parts, total, (e) => e.heart),
        arc: _sum(parts, total, (e) => e.arc),
      );

  static double _sum(
    List<(_EyePose, double)> parts,
    double total,
    double Function(_EyePose) field,
  ) {
    var value = 0.0;
    for (final (eye, weight) in parts) {
      value += field(eye) * weight;
    }
    return value / total;
  }

  static _EyePose lerp(_EyePose a, _EyePose b, double t) => _EyePose(
        open: ui.lerpDouble(a.open, b.open, t)!,
        width: ui.lerpDouble(a.width, b.width, t)!,
        smile: ui.lerpDouble(a.smile, b.smile, t)!,
        droop: ui.lerpDouble(a.droop, b.droop, t)!,
        slant: ui.lerpDouble(a.slant, b.slant, t)!,
        round: ui.lerpDouble(a.round, b.round, t)!,
        heart: ui.lerpDouble(a.heart, b.heart, t)!,
        arc: ui.lerpDouble(a.arc, b.arc, t)!,
      );
}

/// The full parametric pose for one expression. Adding a new emotion is just
/// adding an entry to [_poses].
class _FacePose {
  final _EyePose left;
  final _EyePose right;
  final double mouthCurve; // -1 frown .. 1 smile
  final double mouthOpen; // opens the smile into a laugh
  final double mouthWide;
  final double mouthO; // surprised "o" mouth
  final double mouthWave; // confused squiggle
  final double smirk;
  final double blush;
  final double tilt; // head tilt, radians
  final double energy; // idle motion speed/amplitude
  final double wander; // how restless the gaze is
  final double sparkle;
  final double zzz;
  final double hearts;
  final double tear; // animated teardrop under the left eye
  final double shiver; // horizontal tremble (scared)
  final Offset gazeBias;

  const _FacePose({
    this.left = const _EyePose(),
    this.right = const _EyePose(),
    this.mouthCurve = 0,
    this.mouthOpen = 0,
    this.mouthWide = 1,
    this.mouthO = 0,
    this.mouthWave = 0,
    this.smirk = 0,
    this.blush = 0,
    this.tilt = 0,
    this.energy = 0.6,
    this.wander = 0,
    this.sparkle = 0,
    this.zzz = 0,
    this.hearts = 0,
    this.tear = 0,
    this.shiver = 0,
    this.gazeBias = Offset.zero,
  });

  static _FacePose of(RobotExpression expression) => _poses[expression]!;

  /// The resting anchor for mood blending: softly content, low energy —
  /// where a weak emotion mix settles instead of averaging all ten poses.
  static const _FacePose neutral = _FacePose(
    left: _EyePose(open: 0.92, smile: 0.14, round: 0.6),
    right: _EyePose(open: 0.92, smile: 0.14, round: 0.6),
    mouthCurve: 0.22,
    mouthWide: 0.82,
    blush: 0.15,
    energy: 0.45,
  );

  /// Weighted average of poses (weights need not be normalized). Every field
  /// is linear, so this is the multi-way generalization of [lerp].
  static _FacePose blend(List<(_FacePose, double)> parts) {
    var total = 0.0;
    for (final (_, weight) in parts) {
      total += weight;
    }
    if (total <= 1e-9) return neutral;

    double f(double Function(_FacePose) field) {
      var value = 0.0;
      for (final (pose, weight) in parts) {
        value += field(pose) * weight;
      }
      return value / total;
    }

    var gazeBias = Offset.zero;
    for (final (pose, weight) in parts) {
      gazeBias += pose.gazeBias * weight;
    }

    return _FacePose(
      left: _EyePose.blend(
        [for (final (pose, weight) in parts) (pose.left, weight)],
        total,
      ),
      right: _EyePose.blend(
        [for (final (pose, weight) in parts) (pose.right, weight)],
        total,
      ),
      mouthCurve: f((p) => p.mouthCurve),
      mouthOpen: f((p) => p.mouthOpen),
      mouthWide: f((p) => p.mouthWide),
      mouthO: f((p) => p.mouthO),
      mouthWave: f((p) => p.mouthWave),
      smirk: f((p) => p.smirk),
      blush: f((p) => p.blush),
      tilt: f((p) => p.tilt),
      energy: f((p) => p.energy),
      wander: f((p) => p.wander),
      sparkle: f((p) => p.sparkle),
      zzz: f((p) => p.zzz),
      hearts: f((p) => p.hearts),
      tear: f((p) => p.tear),
      shiver: f((p) => p.shiver),
      gazeBias: gazeBias / total,
    );
  }

  static const Map<RobotExpression, _FacePose> _poses = {
    RobotExpression.happy: _FacePose(
      left: _EyePose(open: 0.95, smile: 0.48),
      right: _EyePose(open: 0.95, smile: 0.48),
      mouthCurve: 0.8,
      mouthWide: 0.9,
      blush: 0.45,
      energy: 0.6,
    ),
    RobotExpression.excited: _FacePose(
      left: _EyePose(open: 1.05, width: 1.05, smile: 0.6, round: 0.6),
      right: _EyePose(open: 1.05, width: 1.05, smile: 0.6, round: 0.6),
      mouthCurve: 1,
      mouthOpen: 0.6,
      mouthWide: 1.05,
      blush: 0.6,
      energy: 1,
      sparkle: 1,
    ),
    RobotExpression.love: _FacePose(
      left: _EyePose(heart: 1),
      right: _EyePose(heart: 1),
      mouthCurve: 0.85,
      mouthWide: 0.8,
      blush: 0.9,
      hearts: 1,
      energy: 0.7,
      tilt: 0.02,
    ),
    RobotExpression.surprised: _FacePose(
      left: _EyePose(open: 1.25, width: 1.12, round: 1),
      right: _EyePose(open: 1.25, width: 1.12, round: 1),
      mouthO: 1,
      mouthOpen: 0.5,
      blush: 0.2,
      energy: 0.75,
      gazeBias: Offset(0, -0.12),
    ),
    RobotExpression.sleepy: _FacePose(
      left: _EyePose(open: 0.45, droop: 0.5, round: 0.5),
      right: _EyePose(open: 0.45, droop: 0.5, round: 0.5),
      mouthCurve: 0.12,
      mouthWide: 0.55,
      blush: 0.12,
      zzz: 1,
      energy: 0.22,
      tilt: -0.03,
      gazeBias: Offset(0, 0.28),
    ),
    RobotExpression.confused: _FacePose(
      left: _EyePose(open: 0.6, width: 0.94, droop: 0.34),
      right: _EyePose(open: 1.08, width: 1.04),
      mouthWave: 1,
      mouthWide: 0.8,
      blush: 0.1,
      energy: 0.5,
      wander: 1,
      tilt: 0.07,
      gazeBias: Offset(0.18, -0.08),
    ),
    RobotExpression.angry: _FacePose(
      left: _EyePose(open: 0.72, slant: 0.85, round: 0.42),
      right: _EyePose(open: 0.72, slant: 0.85, round: 0.42),
      mouthCurve: -0.7,
      mouthWide: 0.85,
      energy: 0.85,
      gazeBias: Offset(0, -0.08),
    ),
    RobotExpression.winking: _FacePose(
      left: _EyePose(arc: 1),
      right: _EyePose(smile: 0.35),
      mouthCurve: 0.7,
      smirk: 0.6,
      mouthWide: 0.9,
      blush: 0.5,
      tilt: 0.04,
      energy: 0.7,
    ),
    RobotExpression.sad: _FacePose(
      left: _EyePose(open: 0.72, slant: -0.55, droop: 0.18, round: 0.5),
      right: _EyePose(open: 0.72, slant: -0.55, droop: 0.18, round: 0.5),
      mouthCurve: -0.55,
      mouthWide: 0.7,
      energy: 0.3,
      tear: 1,
      tilt: -0.02,
      gazeBias: Offset(0, 0.3),
    ),
    RobotExpression.scared: _FacePose(
      left: _EyePose(open: 1.18, width: 0.88, round: 0.85),
      right: _EyePose(open: 1.18, width: 0.88, round: 0.85),
      mouthWave: 1,
      mouthWide: 0.5,
      energy: 0.9,
      shiver: 1,
      gazeBias: Offset(0, -0.18),
    ),
  };

  static _FacePose lerp(_FacePose a, _FacePose b, double t) => _FacePose(
        left: _EyePose.lerp(a.left, b.left, t),
        right: _EyePose.lerp(a.right, b.right, t),
        mouthCurve: ui.lerpDouble(a.mouthCurve, b.mouthCurve, t)!,
        mouthOpen: ui.lerpDouble(a.mouthOpen, b.mouthOpen, t)!,
        mouthWide: ui.lerpDouble(a.mouthWide, b.mouthWide, t)!,
        mouthO: ui.lerpDouble(a.mouthO, b.mouthO, t)!,
        mouthWave: ui.lerpDouble(a.mouthWave, b.mouthWave, t)!,
        smirk: ui.lerpDouble(a.smirk, b.smirk, t)!,
        blush: ui.lerpDouble(a.blush, b.blush, t)!,
        tilt: ui.lerpDouble(a.tilt, b.tilt, t)!,
        energy: ui.lerpDouble(a.energy, b.energy, t)!,
        wander: ui.lerpDouble(a.wander, b.wander, t)!,
        sparkle: ui.lerpDouble(a.sparkle, b.sparkle, t)!,
        zzz: ui.lerpDouble(a.zzz, b.zzz, t)!,
        hearts: ui.lerpDouble(a.hearts, b.hearts, t)!,
        tear: ui.lerpDouble(a.tear, b.tear, t)!,
        shiver: ui.lerpDouble(a.shiver, b.shiver, t)!,
        gazeBias: Offset.lerp(a.gazeBias, b.gazeBias, t)!,
      );
}

/// Paints in a fixed 400x480 design space, uniformly scaled and centered
/// inside whatever box the widget gets.
class _HazeFacePainter extends CustomPainter {
  final bool framed;
  final _FacePose pose;
  final double t;
  final double blinkMul;
  final double blinkStretch;
  final double pop;
  final Offset gaze;
  final Color eyeColor;
  final Color mouthColor;
  final bool isDark;
  final bool speaking;
  final bool thinking;
  final double voiceLevel;

  _HazeFacePainter({
    required this.pose,
    required this.t,
    required this.blinkMul,
    required this.blinkStretch,
    this.framed = true,
    required this.pop,
    required this.gaze,
    required this.eyeColor,
    required this.mouthColor,
    required this.isDark,
    required this.speaking,
    required this.thinking,
    this.voiceLevel = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final viewWidth = framed ? 400.0 : 320.0;
    final viewHeight = framed ? 480.0 : 230.0;
    final s = math.min(size.width / viewWidth, size.height / viewHeight);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    canvas.translate(-200, framed ? -240 : -250);

    if (framed) _drawPanel(canvas);

    final bob = math.sin(t * (1.0 + pose.energy)) * (1.5 + pose.energy * 2.5);
    final breath = 1 + 0.008 * math.sin(t * 0.9) + pop * 0.05;
    final sway = pose.tilt + math.sin(t * 0.6) * 0.012;
    final shiver = math.sin(t * 26) * 1.8 * pose.shiver;
    canvas.save();
    canvas.translate(200 + shiver, 240 + bob);
    canvas.rotate(sway);
    canvas.scale(breath);
    canvas.translate(-200, -240);

    _drawAmbient(canvas);
    _drawCheeks(canvas);
    _drawEye(
      canvas,
      isLeft: true,
      eye: pose.left,
      center: Offset(134 + gaze.dx * 16, 212 + gaze.dy * 12),
    );
    _drawEye(
      canvas,
      isLeft: false,
      eye: pose.right,
      center: Offset(266 + gaze.dx * 16, 212 + gaze.dy * 12),
    );
    _drawMouth(canvas);
    _drawAccents(canvas);
    canvas.restore();

    if (thinking) _drawThinkingDots(canvas);
  }

  void _drawPanel(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 4, 392, 472),
      const Radius.circular(56),
    );
    if (!isDark) {
      // Sitting on a light background the panel reads as a device screen, so
      // give it a soft drop shadow.
      canvas.drawRRect(
        rect.shift(const Offset(0, 10)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10151F), Color(0xFF05070C)],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: isDark ? 0.05 : 0.10),
    );
    // Faint glass sheen across the top of the screen.
    canvas.drawOval(
      const Rect.fromLTWH(60, -40, 280, 130),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  void _drawAmbient(Canvas canvas) {
    final rect = Rect.fromCircle(center: const Offset(200, 220), radius: 180);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            eyeColor.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  void _drawCheeks(Canvas canvas) {
    if (pose.blush < 0.02) return;
    final paint = Paint()
      ..color = Color.lerp(mouthColor, Colors.white, 0.45)!
          .withValues(alpha: pose.blush * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (final x in const [92.0, 308.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 282), width: 62, height: 24),
        paint,
      );
    }
  }

  void _drawEye(
    Canvas canvas, {
    required bool isLeft,
    required _EyePose eye,
    required Offset center,
  }) {
    final bodyAlpha =
        (1 - eye.heart).clamp(0.0, 1.0) * (1 - eye.arc).clamp(0.0, 1.0);
    final w = 90 * eye.width * blinkStretch;
    final h = math.max(10.0, 116 * eye.open * blinkMul);

    if (bodyAlpha > 0.02) {
      final radius = ui.lerpDouble(
        math.min(w, h) * 0.40,
        math.min(w, h) * 0.5,
        eye.round,
      )!;
      var path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: w, height: h),
            Radius.circular(radius),
          ),
        );

      // Bottom lid: raising it turns the eye into a happy crescent (^ ^).
      if (eye.smile > 0.01) {
        final r = w * 1.05;
        final lid = Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(
                center.dx,
                center.dy + h / 2 - eye.smile * h * 0.58 + r,
              ),
              radius: r,
            ),
          );
        path = Path.combine(PathOperation.difference, path, lid);
      }

      // Top lid: straight droop for sleepy, diagonal cut toward the nose for
      // angry (slant > 0) or toward the temple for sad (slant < 0).
      if (eye.droop > 0.01 || eye.slant.abs() > 0.01) {
        final top = center.dy - h / 2;
        final inner = isLeft ? 1.0 : -1.0;
        final drop = eye.droop * h * 0.62;
        final innerDrop = math.max(0.0, eye.slant) * h * 0.55;
        final outerDrop = math.max(0.0, -eye.slant) * h * 0.55;
        final lid = Path()
          ..moveTo(center.dx - inner * w, top - 40)
          ..lineTo(center.dx + inner * w, top - 40)
          ..lineTo(center.dx + inner * w, top + drop + innerDrop)
          ..lineTo(center.dx - inner * w, top + drop + outerDrop)
          ..close();
        path = Path.combine(PathOperation.difference, path, lid);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = eyeColor.withValues(alpha: 0.40 * bodyAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = eyeColor.withValues(alpha: 0.5 * bodyAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(eyeColor, Colors.white, 0.30)!
                  .withValues(alpha: bodyAlpha),
              eyeColor.withValues(alpha: bodyAlpha),
            ],
          ).createShader(
            Rect.fromCenter(center: center, width: w, height: h),
          ),
      );

      if (blinkMul > 0.35 && eye.open > 0.3) {
        // Clip so the gloss never floats outside a lid-cut eye shape.
        canvas.save();
        canvas.clipPath(path);
        final highlight = Offset(
          center.dx - w * 0.20 + gaze.dx * 5,
          center.dy - h * 0.20 + gaze.dy * 5,
        );
        canvas.drawCircle(
          highlight,
          w * 0.11,
          Paint()..color = Colors.white.withValues(alpha: 0.9 * bodyAlpha),
        );
        canvas.drawCircle(
          highlight.translate(w * 0.16, h * 0.14),
          w * 0.055,
          Paint()..color = Colors.white.withValues(alpha: 0.45 * bodyAlpha),
        );
        canvas.restore();
      }
    }

    if (eye.arc > 0.02) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..color = eyeColor.withValues(alpha: 0.95 * eye.arc);
      final arc = Path()
        ..moveTo(center.dx - 45, center.dy + 12)
        ..quadraticBezierTo(center.dx, center.dy - 38, center.dx + 45, center.dy + 12);
      canvas.drawPath(
        arc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round
          ..color = eyeColor.withValues(alpha: 0.35 * eye.arc)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(arc, paint);
    }

    if (eye.heart > 0.02) {
      final pulse = 1 + 0.07 * math.sin(t * 3.2);
      final sz = 54.0 * eye.heart * pulse;
      final heart = _heartPath(center.translate(0, 4), sz);
      canvas.drawPath(
        heart,
        Paint()
          ..color = mouthColor.withValues(alpha: 0.5 * eye.heart)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawPath(
        heart,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(mouthColor, Colors.white, 0.30)!
                  .withValues(alpha: eye.heart),
              mouthColor.withValues(alpha: eye.heart),
            ],
          ).createShader(
            Rect.fromCenter(center: center, width: sz * 2.6, height: sz * 2.4),
          ),
      );
      canvas.drawCircle(
        center.translate(-sz * 0.4, -sz * 0.35),
        sz * 0.16,
        Paint()..color = Colors.white.withValues(alpha: 0.85 * eye.heart),
      );
    }
  }

  void _drawMouth(Canvas canvas) {
    final c = Offset(200 + pose.smirk * 6 + gaze.dx * 6, 332 + gaze.dy * 6);

    if (speaking) {
      // The real loudness of the audio when it plays through SoLoud;
      // otherwise the pseudo-syllable envelope — two detuned sines make it
      // read as speech rather than a metronome.
      final a = (math.sin(t * 10.5) + 1) / 2;
      final b = (math.sin(t * 23.7 + 1.3) + 1) / 2;
      final open01 = voiceLevel > 0.001
          ? voiceLevel.clamp(0.0, 1.0)
          : (0.3 + 0.7 * a) * (0.5 + 0.5 * b);
      final mh = 8 + open01 * 30;
      final mw = 52 - open01 * 16;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: mw, height: mh),
        Radius.circular(mh / 2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = mouthColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawRRect(rect, Paint()..color = mouthColor.withValues(alpha: 0.95));
      return;
    }

    final curveAlpha =
        (1 - pose.mouthO).clamp(0.0, 1.0) * (1 - pose.mouthWave).clamp(0.0, 1.0);
    final halfW = 38.0 * pose.mouthWide;

    if (curveAlpha > 0.02) {
      if (pose.mouthOpen > 0.3) {
        // Open laughing smile.
        final mouth = Path()
          ..moveTo(c.dx - halfW, c.dy - 6)
          ..quadraticBezierTo(c.dx, c.dy + 4, c.dx + halfW, c.dy - 6)
          ..quadraticBezierTo(
            c.dx + pose.smirk * 8,
            c.dy + 12 + pose.mouthOpen * 34,
            c.dx - halfW,
            c.dy - 6,
          )
          ..close();
        canvas.drawPath(
          mouth,
          Paint()..color = mouthColor.withValues(alpha: 0.95 * curveAlpha),
        );
      } else {
        final mouth = Path()
          ..moveTo(c.dx - halfW, c.dy - pose.mouthCurve * 7)
          ..quadraticBezierTo(
            c.dx + pose.smirk * 10,
            c.dy + pose.mouthCurve * 22,
            c.dx + halfW,
            c.dy - pose.mouthCurve * 7 - pose.smirk * 4,
          );
        canvas.drawPath(
          mouth,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8.5
            ..strokeCap = StrokeCap.round
            ..color = mouthColor.withValues(alpha: 0.92 * curveAlpha),
        );
      }
    }

    if (pose.mouthO > 0.02) {
      final r = 13 + pose.mouthOpen * 9;
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 1.7, height: r * 2.1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5
          ..color = mouthColor.withValues(alpha: 0.95 * pose.mouthO),
      );
    }

    if (pose.mouthWave > 0.02) {
      final wave = Path()
        ..moveTo(c.dx - halfW, c.dy + 2)
        ..quadraticBezierTo(c.dx - halfW * 0.5, c.dy - 9, c.dx, c.dy)
        ..quadraticBezierTo(c.dx + halfW * 0.5, c.dy + 9, c.dx + halfW, c.dy - 2);
      canvas.drawPath(
        wave,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5
          ..strokeCap = StrokeCap.round
          ..color = mouthColor.withValues(alpha: 0.92 * pose.mouthWave),
      );
    }
  }

  void _drawAccents(Canvas canvas) {
    if (pose.zzz > 0.02) _drawZs(canvas, pose.zzz);
    if (pose.sparkle > 0.02) _drawSparkles(canvas, pose.sparkle);
    if (pose.hearts > 0.02) _drawMiniHearts(canvas, pose.hearts);
    if (pose.tear > 0.02) _drawTear(canvas, pose.tear);
  }

  void _drawTear(Canvas canvas, double alpha) {
    // One teardrop welling up under the left eye's outer corner, sliding
    // down and fading, on a slow loop.
    final phase = (t * 0.55) % 1.0;
    final grow = math.min(1.0, phase / 0.25);
    final fade = phase < 0.7 ? 1.0 : 1 - (phase - 0.7) / 0.3;
    final c = Offset(100 + gaze.dx * 6, 272 + phase * 30);
    final s = 8.0 * grow;
    if (s < 1) return;
    const tearColor = Color(0xFFA8DCFF);
    final tear = Path()
      ..moveTo(c.dx, c.dy - s * 1.4)
      ..quadraticBezierTo(c.dx + s * 0.9, c.dy - s * 0.25, c.dx + s * 0.85, c.dy + s * 0.3)
      ..arcToPoint(
        Offset(c.dx - s * 0.85, c.dy + s * 0.3),
        radius: Radius.circular(s * 0.9),
        clockwise: true,
      )
      ..quadraticBezierTo(c.dx - s * 0.9, c.dy - s * 0.25, c.dx, c.dy - s * 1.4)
      ..close();
    canvas.drawPath(
      tear,
      Paint()..color = tearColor.withValues(alpha: 0.85 * alpha * fade),
    );
    canvas.drawCircle(
      c.translate(-s * 0.25, -s * 0.1),
      s * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.8 * alpha * fade),
    );
  }

  void _drawZs(Canvas canvas, double alpha) {
    for (var i = 0; i < 3; i++) {
      final rise = (t * 10 + i * 15) % 44;
      final a = alpha * (1 - rise / 44) * 0.85;
      final sz = 5.0 + i * 1.8;
      final c = Offset(292 + i * 15.0, 138 - i * 11.0 - rise);
      final z = Path()
        ..moveTo(c.dx - sz, c.dy - sz)
        ..lineTo(c.dx + sz, c.dy - sz)
        ..lineTo(c.dx - sz, c.dy + sz)
        ..lineTo(c.dx + sz, c.dy + sz);
      canvas.drawPath(
        z,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = eyeColor.withValues(alpha: a.clamp(0.0, 1.0)),
      );
    }
  }

  void _drawSparkles(Canvas canvas, double alpha) {
    const spots = [
      Offset(80, 122),
      Offset(320, 108),
      Offset(62, 218),
      Offset(338, 226),
    ];
    final color = Color.lerp(eyeColor, Colors.white, 0.6)!;
    for (var i = 0; i < spots.length; i++) {
      final tw = 0.5 + 0.5 * math.sin(t * 4.2 + i * 1.7);
      if (tw < 0.15) continue;
      final sz = 4.0 + 6.0 * tw;
      canvas.drawPath(
        _sparklePath(spots[i], sz),
        Paint()..color = color.withValues(alpha: alpha * tw * 0.9),
      );
    }
  }

  void _drawMiniHearts(Canvas canvas, double alpha) {
    const spots = [Offset(90, 126), Offset(312, 110)];
    for (var i = 0; i < spots.length; i++) {
      final pulse = 1 + 0.14 * math.sin(t * 3 + i * 1.8);
      final c = spots[i].translate(0, math.sin(t * 1.4 + i) * 4);
      canvas.drawPath(
        _heartPath(c, (10.0 - i * 2) * pulse),
        Paint()..color = mouthColor.withValues(alpha: 0.85 * alpha),
      );
    }
  }

  void _drawThinkingDots(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final ph = math.sin(t * 3.4 - i * 0.55);
      final lift = math.max(0.0, ph) * 8;
      canvas.drawCircle(
        Offset(276 + i * 22.0, 118 - lift),
        6.5,
        Paint()
          ..color =
              eyeColor.withValues(alpha: 0.25 + 0.55 * math.max(0.0, ph)),
      );
    }
  }

  Path _sparklePath(Offset c, double s) => Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx + s * 0.18, c.dy - s * 0.18, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx + s * 0.18, c.dy + s * 0.18, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx - s * 0.18, c.dy + s * 0.18, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx - s * 0.18, c.dy - s * 0.18, c.dx, c.dy - s)
    ..close();

  Path _heartPath(Offset center, double size) => Path()
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

  @override
  bool shouldRepaint(covariant _HazeFacePainter oldDelegate) =>
      oldDelegate.t != t;
}
