import '../chemistry/chemistry.dart';
import '../models/robot_config.dart';

/// Haze's living mood: the neurochemical engine bound to wall-clock time and
/// to the app's events.
///
/// Nothing here stores an emotion. Pokes, cuddles, wins and scares push
/// chemical impulses in; the engine decays and cross-couples them on its own
/// timescales (an adrenaline flash fades in minutes, a serotonin dip lasts
/// hours); the face and the lab read projections out. The engine is advanced
/// lazily — every read fast-forwards the simulation by however much real time
/// has passed, so there is no background timer.
class HazeMood {
  final NeurochemicalEngine _engine = NeurochemicalEngine();
  final DateTime Function() _now;
  DateTime _lastSync;

  DateTime? _holdUntil;

  /// While true (feelings game rounds), the acted expression owns the face
  /// and the mood never shows through — a kid mid-round needs a stable face.
  bool pinned = false;

  /// Fired after every impulse batch — the cubit hangs persistence off it.
  void Function()? onChanged;

  HazeMood({DateTime Function()? clock})
      : _now = clock ?? DateTime.now,
        _lastSync = (clock ?? DateTime.now)();

  /// Beyond this, catch-up switches to one exact analytic decay step: the
  /// engine sub-steps at 0.5 s, so simulating a day of suspension would be
  /// ~170k synchronous iterations on the UI isolate. Pure decay is exact for
  /// any dt, and after that long the interaction terms (all gated on
  /// excess-above-baseline) are negligible — only a short tail is simulated.
  static const double _maxSimulatedCatchUp = 600; // seconds

  void _sync() {
    final now = _now();
    final elapsed = now.difference(_lastSync).inMilliseconds / 1000.0;
    _lastSync = now;
    _advanceWall(elapsed);
  }

  void _advanceWall(double elapsed) {
    if (elapsed <= 0) return;
    if (elapsed > _maxSimulatedCatchUp) {
      _engine.state.decayAll(elapsed - _maxSimulatedCatchUp);
      elapsed = _maxSimulatedCatchUp;
    }
    _engine.advance(elapsed);
  }

  // --- Projections -------------------------------------------------------

  EmotionVector emotions() {
    _sync();
    return EmotionVector.compute(_engine.state);
  }

  Map<Chemical, double> levels() {
    _sync();
    return _engine.state.levels;
  }

  Map<Chemical, double> baselines() => _engine.state.baselines;

  double level(Chemical chem) {
    _sync();
    return _engine.state.get(chem);
  }

  /// The face Haze would make about its current chemistry — used where a
  /// discrete [RobotExpression] is needed (non-V3 faces, speech tone).
  RobotExpression dominantExpression() => switch (emotions().dominant) {
        Emotion.happiness => RobotExpression.happy,
        Emotion.excitement || Emotion.euphoria => RobotExpression.excited,
        Emotion.anger => RobotExpression.angry,
        Emotion.calm => RobotExpression.happy,
        Emotion.bonding => RobotExpression.love,
        Emotion.anxiety => RobotExpression.scared,
        Emotion.sadness => RobotExpression.sad,
      };

  // --- Expression holds --------------------------------------------------

  /// An explicit face (game round, easter egg, brain reply) holds the screen
  /// for a while before the mood shows through again.
  void holdExpression([Duration duration = const Duration(seconds: 7)]) {
    _holdUntil = _now().add(duration);
  }

  bool get moodDriven =>
      !pinned && (_holdUntil == null || _now().isAfter(_holdUntil!));

  // --- Personality -------------------------------------------------------

  /// Reseed for a personality (name matches `HazePersonality.name`). The
  /// mood of the moment survives; only the resting nature changes.
  void setPersonality(String name) {
    _sync();
    _engine.reseed(SeedChemistry.forPersonality(name));
  }

  // --- Event impulses ----------------------------------------------------
  //
  // Deltas are tuned against the half-lives: a poke is a flicker, a cuddle
  // meaningfully warms the next half hour. Source ids make repeats of the
  // same trick wear off (engine-level saturation).

  void _apply(List<ChemicalImpulse> impulses) {
    _sync();
    _engine.applyAll(impulses);
    onChanged?.call();
  }

  /// Raw impulse access for scripted moments (the mix game's "life happened"
  /// perturbations). Prefer the named event methods for real interactions.
  void applyImpulses(List<ChemicalImpulse> impulses) => _apply(impulses);

  void poked() => _apply(const [
        ChemicalImpulse(Chemical.dopamine, 0.05, sourceId: 'poke'),
        ChemicalImpulse(Chemical.adrenaline, 0.04, sourceId: 'poke'),
      ]);

  void annoyed() => _apply(const [
        ChemicalImpulse(Chemical.cortisol, 0.10, sourceId: 'annoy'),
        ChemicalImpulse(Chemical.testosterone, 0.06, sourceId: 'annoy'),
        ChemicalImpulse(Chemical.adrenaline, 0.06, sourceId: 'annoy'),
      ]);

  void tickled() => _apply(const [
        ChemicalImpulse(Chemical.endorphins, 0.25, sourceId: 'tickle'),
        ChemicalImpulse(Chemical.dopamine, 0.15, sourceId: 'tickle'),
        ChemicalImpulse(Chemical.adrenaline, 0.10, sourceId: 'tickle'),
      ]);

  void cuddled() => _apply(const [
        ChemicalImpulse(Chemical.oxytocin, 0.30, sourceId: 'cuddle'),
        ChemicalImpulse(Chemical.endorphins, 0.12, sourceId: 'cuddle'),
      ]);

  void shaken() => _apply(const [
        ChemicalImpulse(Chemical.adrenaline, 0.30, sourceId: 'shake'),
        ChemicalImpulse(Chemical.cortisol, 0.12, sourceId: 'shake'),
      ]);

  void wokeUp() => _apply(const [
        ChemicalImpulse(Chemical.adrenaline, 0.15, sourceId: 'wake'),
      ]);

  void sang() => _apply(const [
        ChemicalImpulse(Chemical.oxytocin, 0.15, sourceId: 'sing'),
        ChemicalImpulse(Chemical.endorphins, 0.15, sourceId: 'sing'),
      ]);

  void timerStarted() => _apply(const [
        ChemicalImpulse(Chemical.dopamine, 0.08, sourceId: 'timer'),
      ]);

  void timerFinished() => _apply(const [
        ChemicalImpulse(Chemical.dopamine, 0.20, sourceId: 'timer'),
        ChemicalImpulse(Chemical.endorphins, 0.10, sourceId: 'timer'),
        ChemicalImpulse(Chemical.adrenaline, 0.08, sourceId: 'timer'),
      ]);

  void gameCorrect() => _apply(const [
        ChemicalImpulse(Chemical.dopamine, 0.12, sourceId: 'game-correct'),
      ]);

  void gameStreak() => _apply(const [
        ChemicalImpulse(Chemical.endorphins, 0.15, sourceId: 'game-streak'),
        ChemicalImpulse(Chemical.dopamine, 0.10, sourceId: 'game-streak'),
        ChemicalImpulse(Chemical.oxytocin, 0.05, sourceId: 'game-streak'),
      ]);

  void gameWrong() => _apply(const [
        ChemicalImpulse(Chemical.cortisol, 0.05, sourceId: 'game-wrong'),
      ]);

  /// Haze committed to a feeling (brain reply tag, or acting a face the user
  /// cycled to) — method acting: making the face nudges the chemistry.
  void reactedTo(RobotExpression emotion, {String sourceId = 'acted'}) {
    _apply([
      for (final (chem, delta) in _actingImpulses(emotion))
        ChemicalImpulse(chem, delta, sourceId: sourceId),
    ]);
  }

  List<(Chemical, double)> _actingImpulses(RobotExpression emotion) =>
      switch (emotion) {
        RobotExpression.happy => const [
            (Chemical.dopamine, 0.10),
            (Chemical.serotonin, 0.05),
          ],
        RobotExpression.excited => const [
            (Chemical.dopamine, 0.12),
            (Chemical.adrenaline, 0.12),
          ],
        RobotExpression.love => const [
            (Chemical.oxytocin, 0.20),
            (Chemical.endorphins, 0.08),
          ],
        RobotExpression.sad => const [
            (Chemical.dopamine, -0.10),
            (Chemical.serotonin, -0.08),
            (Chemical.cortisol, 0.08),
          ],
        RobotExpression.angry => const [
            (Chemical.testosterone, 0.12),
            (Chemical.cortisol, 0.10),
            (Chemical.adrenaline, 0.08),
            (Chemical.gaba, -0.05),
          ],
        RobotExpression.scared => const [
            (Chemical.adrenaline, 0.20),
            (Chemical.cortisol, 0.12),
          ],
        RobotExpression.surprised => const [(Chemical.adrenaline, 0.15)],
        RobotExpression.sleepy => const [
            (Chemical.gaba, 0.10),
            (Chemical.adrenaline, -0.05),
          ],
        RobotExpression.confused => const [
            (Chemical.cortisol, 0.04),
            (Chemical.adrenaline, 0.04),
          ],
        RobotExpression.winking => const [
            (Chemical.dopamine, 0.08),
            (Chemical.oxytocin, 0.05),
          ],
      };

  /// Lab: hand-feed one chemical and watch what happens. Saturation is per
  /// chemical so spamming one bar wears off without numbing the others.
  void dose(Chemical chem, [double delta = 0.2]) =>
      _apply([ChemicalImpulse(chem, delta, sourceId: 'lab-${chem.name}')]);

  /// Lab: settle everything straight back to its resting level.
  void resetToBaseline() {
    _sync();
    for (final chem in Chemical.values) {
      _engine.state.set(chem, _engine.state.baseline(chem));
    }
    onChanged?.call();
  }

  // --- Persistence -------------------------------------------------------

  /// Levels + timestamp. Baselines are not saved — they re-derive from the
  /// persisted personality on restore.
  Map<String, dynamic> toJson() => {
        'levels': {
          for (final entry in levels().entries) entry.key.name: entry.value,
        },
        'savedAt': _now().toIso8601String(),
      };

  /// Restore a previous session's chemistry, then let it decay by however
  /// long the app was closed — Haze kept feeling things while it was away.
  void restore(Map<String, dynamic> json) {
    final levels = json['levels'];
    if (levels is! Map) return;
    for (final chem in Chemical.values) {
      final value = levels[chem.name];
      if (value is num) _engine.state.set(chem, value.toDouble());
    }
    final savedAt = DateTime.tryParse(json['savedAt']?.toString() ?? '');
    if (savedAt != null) {
      // Haze kept feeling things while the app was away; the analytic fast
      // path makes even weeks of absence a constant-time catch-up.
      _advanceWall(_now().difference(savedAt).inMilliseconds / 1000.0);
    }
    _lastSync = _now();
  }
}
