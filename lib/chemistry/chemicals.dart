import 'dart:math' as math;

/// The 8 simulated neurochemicals behind Haze's moods.
///
/// Ported from the kindalive project (MIT, github.com/smithandrewjohn/
/// kindalive): emotions are never stored — only these concentrations are,
/// and every mood or face is a read-only projection of them.
enum Chemical {
  dopamine,
  serotonin,
  oxytocin,
  testosterone,
  cortisol,
  adrenaline,
  endorphins,
  gaba,
}

/// Species-default resting level and half-life (seconds) per chemical.
/// Half-lives are what give moods their texture: adrenaline is a 3-minute
/// flash, serotonin a 4-hour tide.
class ChemicalDefaults {
  final double baseline;
  final double halfLife;

  const ChemicalDefaults({required this.baseline, required this.halfLife});
}

const Map<Chemical, ChemicalDefaults> speciesDefaults = {
  Chemical.dopamine: ChemicalDefaults(baseline: 0.3, halfLife: 1200), // 20 min
  Chemical.serotonin: ChemicalDefaults(baseline: 0.5, halfLife: 14400), // 4 h
  Chemical.oxytocin: ChemicalDefaults(baseline: 0.2, halfLife: 1800), // 30 min
  Chemical.testosterone: ChemicalDefaults(baseline: 0.3, halfLife: 7200), // 2 h
  Chemical.cortisol: ChemicalDefaults(baseline: 0.2, halfLife: 3600), // 1 h
  Chemical.adrenaline: ChemicalDefaults(baseline: 0.1, halfLife: 180), // 3 min
  Chemical.endorphins: ChemicalDefaults(baseline: 0.2, halfLife: 1800), // 30 m
  Chemical.gaba: ChemicalDefaults(baseline: 0.4, halfLife: 3600), // 1 h
};

/// Baselines may drift at runtime (chronic stress raises the cortisol
/// baseline) but only inside this band, so a robot can be worn down or
/// healed without ever losing its underlying nature.
const double baselineDriftMin = 0.1;
const double baselineDriftMax = 0.5;

/// Mutable vector of the 8 concentrations, each clamped to [0, 1], plus the
/// per-chemical baselines and half-lives they decay toward and with.
class ChemicalState {
  final Map<Chemical, double> _levels;
  final Map<Chemical, double> _baselines;
  final Map<Chemical, double> _halfLives;

  ChemicalState({
    Map<Chemical, double>? baselines,
    Map<Chemical, double>? halfLives,
  })  : _levels = {},
        _baselines = {},
        _halfLives = {} {
    for (final chem in Chemical.values) {
      final defaults = speciesDefaults[chem]!;
      final bl = baselines?[chem] ?? defaults.baseline;
      _baselines[chem] = bl;
      _halfLives[chem] = halfLives?[chem] ?? defaults.halfLife;
      _levels[chem] = bl; // start at rest
    }
  }

  ChemicalState._copy(this._levels, this._baselines, this._halfLives);

  double get(Chemical chem) => _levels[chem]!;

  void set(Chemical chem, double value) {
    _levels[chem] = value.clamp(0.0, 1.0);
  }

  double baseline(Chemical chem) => _baselines[chem]!;

  void setBaseline(Chemical chem, double value) {
    _baselines[chem] = value.clamp(baselineDriftMin, baselineDriftMax);
  }

  double halfLife(Chemical chem) => _halfLives[chem]!;

  void clampAll() {
    for (final chem in Chemical.values) {
      _levels[chem] = _levels[chem]!.clamp(0.0, 1.0);
    }
  }

  /// Exponential decay toward baseline using a true half-life:
  /// level += (baseline - level) * (1 - 2^(-dt / halfLife)).
  void applyDecay(Chemical chem, double dt) {
    final level = _levels[chem]!;
    final bl = _baselines[chem]!;
    final factor = 1.0 - math.pow(2.0, -dt / _halfLives[chem]!);
    _levels[chem] = level + (bl - level) * factor;
  }

  void decayAll(double dt) {
    for (final chem in Chemical.values) {
      applyDecay(chem, dt);
    }
  }

  Map<Chemical, double> get levels => Map.unmodifiable(_levels);

  Map<Chemical, double> get baselines => Map.unmodifiable(_baselines);

  ChemicalState copy() => ChemicalState._copy(
        Map.of(_levels),
        Map.of(_baselines),
        Map.of(_halfLives),
      );
}
