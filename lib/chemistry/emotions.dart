import 'chemicals.dart';

/// The 8 emotions Haze can *have* — computed from chemistry, never stored.
/// (Distinct from [RobotExpression], the faces Haze can *make*.)
enum Emotion {
  happiness,
  excitement,
  anger,
  calm,
  bonding,
  anxiety,
  sadness,
  euphoria,
}

/// One weighted term in an emotion's linear combination. When [inverted],
/// the term contributes the *deficit* below baseline — a robot is only sad
/// when dopamine falls below its usual level, not whenever it is under 1.0.
class EmotionTerm {
  final Chemical chemical;
  final double weight;
  final bool inverted;

  const EmotionTerm(this.chemical, this.weight, {this.inverted = false});

  double evaluate(ChemicalState state) {
    if (inverted) {
      final deficit =
          (state.baseline(chemical) - state.get(chemical)).clamp(0.0, 1.0);
      return weight * deficit;
    }
    return weight * state.get(chemical);
  }
}

/// Single source of truth for the emotion formulas — the lab UI reads this
/// to show "why does Haze feel this way?" breakdowns.
const Map<Emotion, List<EmotionTerm>> emotionWeights = {
  Emotion.happiness: [
    EmotionTerm(Chemical.dopamine, 0.35),
    EmotionTerm(Chemical.serotonin, 0.35),
    EmotionTerm(Chemical.endorphins, 0.15),
    EmotionTerm(Chemical.oxytocin, 0.15),
    EmotionTerm(Chemical.cortisol, -0.20),
  ],
  Emotion.excitement: [
    EmotionTerm(Chemical.adrenaline, 0.45),
    EmotionTerm(Chemical.dopamine, 0.35),
    EmotionTerm(Chemical.testosterone, 0.20),
  ],
  Emotion.anger: [
    EmotionTerm(Chemical.testosterone, 0.35),
    EmotionTerm(Chemical.cortisol, 0.35),
    EmotionTerm(Chemical.adrenaline, 0.30),
    EmotionTerm(Chemical.gaba, -0.30),
  ],
  Emotion.calm: [
    EmotionTerm(Chemical.gaba, 0.45),
    EmotionTerm(Chemical.serotonin, 0.35),
    EmotionTerm(Chemical.oxytocin, 0.20),
    EmotionTerm(Chemical.adrenaline, -0.25),
    EmotionTerm(Chemical.cortisol, -0.15),
  ],
  Emotion.bonding: [
    EmotionTerm(Chemical.oxytocin, 0.50),
    EmotionTerm(Chemical.serotonin, 0.30),
    EmotionTerm(Chemical.endorphins, 0.20),
  ],
  Emotion.anxiety: [
    EmotionTerm(Chemical.cortisol, 0.40),
    EmotionTerm(Chemical.adrenaline, 0.35),
    EmotionTerm(Chemical.testosterone, 0.25),
    EmotionTerm(Chemical.gaba, -0.35),
    EmotionTerm(Chemical.serotonin, -0.15),
  ],
  Emotion.sadness: [
    EmotionTerm(Chemical.cortisol, 0.60),
    EmotionTerm(Chemical.dopamine, 0.50, inverted: true),
    EmotionTerm(Chemical.serotonin, 0.40, inverted: true),
    EmotionTerm(Chemical.oxytocin, 0.40, inverted: true),
  ],
  Emotion.euphoria: [
    EmotionTerm(Chemical.dopamine, 0.30),
    EmotionTerm(Chemical.endorphins, 0.30),
    EmotionTerm(Chemical.adrenaline, 0.20),
    EmotionTerm(Chemical.oxytocin, 0.20),
  ],
};

/// A read-only snapshot of all 8 emotion intensities in [0, 1].
class EmotionVector {
  final Map<Emotion, double> values;

  const EmotionVector(this.values);

  double operator [](Emotion emotion) => values[emotion]!;

  Emotion get dominant => values.entries
      .reduce((a, b) => b.value > a.value ? b : a)
      .key;

  /// Emotions sorted strongest-first.
  List<MapEntry<Emotion, double>> ranked() {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  static EmotionVector compute(ChemicalState state) => EmotionVector({
        for (final entry in emotionWeights.entries)
          entry.key: entry.value
              .fold(0.0, (sum, term) => sum + term.evaluate(state))
              .clamp(0.0, 1.0),
      });
}
