import 'chemistry.dart';

/// Curated examples of Haze's model, not human neurochemistry recipes.
enum LabReference {
  content(Emotion.happiness, Chemical.dopamine, [
    0.65,
    0.75,
    0.35,
    0.15,
    0.1,
    0.1,
    0.35,
    0.45,
  ]),
  excited(Emotion.excitement, Chemical.adrenaline, [
    0.65,
    0.4,
    0.2,
    0.5,
    0.1,
    0.8,
    0.25,
    0.2,
  ]),
  affectionate(Emotion.bonding, Chemical.oxytocin, [
    0.35,
    0.55,
    0.8,
    0.15,
    0.1,
    0.1,
    0.4,
    0.35,
  ]),
  tense(Emotion.anger, Chemical.gaba, [
    0.45,
    0.45,
    0.3,
    0.65,
    0.65,
    0.6,
    0.15,
    0.15,
  ]),
  sad(Emotion.sadness, Chemical.serotonin, [
    0.05,
    0.1,
    0.05,
    0.15,
    0.65,
    0.1,
    0.1,
    0.25,
  ]);

  const LabReference(this.emotion, this.experiment, this._levels);
  final Emotion emotion;
  final Chemical experiment;
  final List<double> _levels;
  Map<Chemical, double> get levels => {
    for (final chemical in Chemical.values) chemical: _levels[chemical.index],
  };
}
