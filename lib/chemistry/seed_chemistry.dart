import 'chemicals.dart';

/// A robot's nature: resting baselines, how fast feelings fade, and how
/// strongly the chemicals push each other around. Keyed by personality name
/// (matches `HazePersonality.name`) so this module stays Flutter-free.
class SeedChemistry {
  final Map<Chemical, double> baselines;
  final Map<Chemical, double> halfLifeMultipliers;
  final double interactionScale;

  const SeedChemistry({
    this.baselines = const {},
    this.halfLifeMultipliers = const {},
    this.interactionScale = 1.0,
  });

  double effectiveBaseline(Chemical chem) =>
      baselines[chem] ?? speciesDefaults[chem]!.baseline;

  double effectiveHalfLife(Chemical chem) =>
      speciesDefaults[chem]!.halfLife * (halfLifeMultipliers[chem] ?? 1.0);

  Map<Chemical, double> allBaselines() => {
        for (final chem in Chemical.values) chem: effectiveBaseline(chem),
      };

  Map<Chemical, double> allHalfLives() => {
        for (final chem in Chemical.values) chem: effectiveHalfLife(chem),
      };

  /// Seed for one of Haze's personalities; unknown names get the default.
  static SeedChemistry forPersonality(String name) =>
      _presets[name] ?? const SeedChemistry();

  static const Map<String, SeedChemistry> _presets = {
    // Bubbly and up for anything: sunny resting mood, quick to delight.
    'playful': SeedChemistry(
      baselines: {
        Chemical.serotonin: 0.6,
        Chemical.dopamine: 0.45,
        Chemical.endorphins: 0.3,
        Chemical.adrenaline: 0.12,
      },
      interactionScale: 1.1,
    ),
    // Dry wit: a touch more drive and vigilance, a little less snuggle.
    'sarcastic': SeedChemistry(
      baselines: {
        Chemical.testosterone: 0.38,
        Chemical.cortisol: 0.22,
        Chemical.oxytocin: 0.18,
        Chemical.dopamine: 0.32,
      },
    ),
    // Cozy and slow: heavy calm blanket, excitement burns out fast.
    'sleepy': SeedChemistry(
      baselines: {
        Chemical.gaba: 0.55,
        Chemical.serotonin: 0.55,
        Chemical.dopamine: 0.25,
        Chemical.adrenaline: 0.06,
      },
      halfLifeMultipliers: {Chemical.adrenaline: 0.6},
      interactionScale: 0.8,
    ),
    // Even-keeled monk: stress and thrill both wash off quickly.
    'zen': SeedChemistry(
      baselines: {
        Chemical.gaba: 0.6,
        Chemical.serotonin: 0.55,
        Chemical.adrenaline: 0.08,
        Chemical.cortisol: 0.15,
      },
      halfLifeMultipliers: {
        Chemical.adrenaline: 0.7,
        Chemical.cortisol: 0.8,
      },
      interactionScale: 0.7,
    ),
    // Deeper still than zen, with extra warmth for guided rest.
    'meditative': SeedChemistry(
      baselines: {
        Chemical.gaba: 0.65,
        Chemical.serotonin: 0.55,
        Chemical.oxytocin: 0.3,
        Chemical.adrenaline: 0.06,
        Chemical.cortisol: 0.12,
      },
      halfLifeMultipliers: {
        Chemical.adrenaline: 0.6,
        Chemical.cortisol: 0.7,
      },
      interactionScale: 0.6,
    ),
  };
}
