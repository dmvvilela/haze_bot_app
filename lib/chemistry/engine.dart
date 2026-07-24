import 'chemicals.dart';
import 'impulse.dart';
import 'interactions.dart';
import 'seed_chemistry.dart';

/// Sub-step ceiling for numerical stability.
const double maxSubStep = 0.5; // seconds

/// Saturation: same-source impulses inside this window are dampened.
const double saturationWindow = 300.0; // 5 minutes
const double saturationDampening = 0.3;

/// The core simulation loop: holds the [ChemicalState], applies impulses
/// (instant and sustained), and advances time with decay + interactions.
/// Pure math on a simulated clock — the caller decides how sim time maps to
/// wall time.
class NeurochemicalEngine {
  ChemicalState state;
  SeedChemistry _seed;
  final List<ActiveSustainedImpulse> _sustained = [];
  final Map<String, List<double>> _saturation = {};
  double _simTime = 0;

  NeurochemicalEngine({SeedChemistry? seed})
      : _seed = seed ?? const SeedChemistry(),
        state = ChemicalState(
          baselines: (seed ?? const SeedChemistry()).allBaselines(),
          halfLives: (seed ?? const SeedChemistry()).allHalfLives(),
        );

  SeedChemistry get seed => _seed;

  /// Swap the robot's nature (personality change) while keeping its current
  /// levels — the mood of the moment survives, but it now decays toward the
  /// new resting state.
  void reseed(SeedChemistry seed) {
    _seed = seed;
    final fresh = ChemicalState(
      baselines: seed.allBaselines(),
      halfLives: seed.allHalfLives(),
    );
    for (final chem in Chemical.values) {
      fresh.set(chem, state.get(chem));
    }
    state = fresh;
  }

  void apply(ChemicalImpulse impulse) {
    final effectiveDelta = _saturated(impulse);
    if (impulse.durationSeconds > 0) {
      _sustained.add(
        ActiveSustainedImpulse(
          ChemicalImpulse(
            impulse.chemical,
            effectiveDelta,
            durationSeconds: impulse.durationSeconds,
            sourceId: impulse.sourceId,
          ),
        ),
      );
    } else {
      state.set(impulse.chemical, state.get(impulse.chemical) + effectiveDelta);
    }
  }

  void applyAll(Iterable<ChemicalImpulse> impulses) {
    for (final impulse in impulses) {
      apply(impulse);
    }
  }

  double _saturated(ChemicalImpulse impulse) {
    if (impulse.sourceId.isEmpty) return impulse.delta;
    final times = _saturation.putIfAbsent(impulse.sourceId, () => []);
    times.removeWhere((t) => _simTime - t >= saturationWindow);
    final factor = 1.0 / (1.0 + times.length * saturationDampening);
    times.add(_simTime);
    return impulse.delta * factor;
  }

  /// Advance the simulation by [dt] seconds, sub-stepping for stability.
  /// Each sub-step: sustained drips → decay → interactions → clamp.
  void advance(double dt) {
    assert(dt >= 0, 'dt must be >= 0, got $dt');
    var remaining = dt;
    while (remaining > 1e-9) {
      final step = remaining < maxSubStep ? remaining : maxSubStep;
      _subStep(step);
      remaining -= step;
    }
  }

  void _subStep(double dt) {
    _simTime += dt;

    for (final active in _sustained) {
      final dripDt =
          dt < active.remainingSeconds ? dt : active.remainingSeconds;
      if (dripDt > 0) {
        final chem = active.impulse.chemical;
        state.set(chem, state.get(chem) + active.ratePerSecond * dripDt);
        active.remainingSeconds -= dripDt;
      }
    }
    _sustained.removeWhere((active) => active.remainingSeconds <= 1e-9);

    state.decayAll(dt);
    applyInteractions(state, dt, scale: _seed.interactionScale);
    state.clampAll();
  }
}
