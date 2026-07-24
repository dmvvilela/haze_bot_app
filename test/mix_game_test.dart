import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/chemistry/chemistry.dart';
import 'package:haze_bot_app/cubits/mix_game_cubit.dart';
import 'package:haze_bot_app/services/haze_mood.dart';

EmotionVector _vector(Map<Emotion, double> overrides) => EmotionVector({
      for (final emotion in Emotion.values) emotion: overrides[emotion] ?? 0.1,
    });

void main() {
  group('isMixSolved', () {
    test('needs the threshold', () {
      expect(
        isMixSolved(_vector({Emotion.anger: 0.45}), Emotion.anger),
        isFalse,
      );
      expect(
        isMixSolved(_vector({Emotion.anger: 0.55}), Emotion.anger),
        isTrue,
      );
    });

    test('needs the target to be at least co-dominant', () {
      final buried = _vector({
        Emotion.excitement: 0.6,
        Emotion.euphoria: 0.8,
        Emotion.happiness: 0.7,
      });
      // Excitement clears its threshold but ranks third — not solved.
      expect(isMixSolved(buried, Emotion.excitement), isFalse);
      // Second place is good enough: the overlap with euphoria is real.
      final second = _vector({Emotion.excitement: 0.6, Emotion.euphoria: 0.7});
      expect(isMixSolved(second, Emotion.excitement), isTrue);
    });
  });

  group('pickMixTarget', () {
    test('avoids the previous target and nearly-won emotions', () {
      final emotions = _vector({Emotion.calm: 0.6, Emotion.happiness: 0.5});
      for (var seed = 0; seed < 20; seed++) {
        final target = pickMixTarget(
          emotions,
          previous: Emotion.bonding,
          random: math.Random(seed),
        );
        expect(target, isNot(Emotion.bonding));
        expect(target, isNot(Emotion.calm)); // already ≥ threshold − 0.1
        expect(target, isNot(Emotion.happiness));
      }
    });

    test('falls back to the weakest emotion when everything is high', () {
      final maxed = _vector({
        for (final emotion in Emotion.values) emotion: 0.9,
        Emotion.sadness: 0.85,
      });
      expect(
        pickMixTarget(maxed, previous: null, random: math.Random(1)),
        Emotion.sadness,
      );
    });
  });

  group('mixPerturbation', () {
    test('soothing targets get stressed first, agitated targets mellowed', () {
      final startle = mixPerturbation(Emotion.calm);
      expect(
        startle
            .firstWhere((i) => i.chemical == Chemical.cortisol)
            .delta,
        greaterThan(0),
      );
      final mellow = mixPerturbation(Emotion.anger);
      expect(
        mellow.firstWhere((i) => i.chemical == Chemical.gaba).delta,
        greaterThan(0),
      );
      expect(
        mellow.firstWhere((i) => i.chemical == Chemical.adrenaline).delta,
        lessThan(0),
      );
    });
  });

  group('every emotion is winnable with lab doses', () {
    // One plausible kid-recipe per emotion, ±0.2 doses only, from a resting
    // default robot. If a weight tweak ever breaks one of these, the game
    // has an unwinnable round — that's the regression this guards against.
    const recipes = <Emotion, List<(Chemical, double)>>{
      Emotion.happiness: [
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.serotonin, 0.2),
        (Chemical.serotonin, 0.2),
        (Chemical.oxytocin, 0.2),
        (Chemical.endorphins, 0.2),
      ],
      Emotion.excitement: [
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.testosterone, 0.2),
      ],
      Emotion.anger: [
        (Chemical.testosterone, 0.2),
        (Chemical.testosterone, 0.2),
        (Chemical.testosterone, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.gaba, -0.2),
        (Chemical.gaba, -0.2),
      ],
      Emotion.calm: [
        (Chemical.gaba, 0.2),
        (Chemical.gaba, 0.2),
        (Chemical.serotonin, 0.2),
        (Chemical.oxytocin, 0.2),
      ],
      Emotion.bonding: [
        (Chemical.oxytocin, 0.2),
        (Chemical.oxytocin, 0.2),
        (Chemical.oxytocin, 0.2),
        (Chemical.serotonin, 0.2),
        (Chemical.endorphins, 0.2),
      ],
      Emotion.anxiety: [
        (Chemical.cortisol, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.testosterone, 0.2),
        (Chemical.gaba, -0.2),
        (Chemical.gaba, -0.2),
        (Chemical.serotonin, -0.2),
      ],
      Emotion.sadness: [
        (Chemical.cortisol, 0.2),
        (Chemical.cortisol, 0.2),
        (Chemical.dopamine, -0.2),
        (Chemical.dopamine, -0.2),
        (Chemical.serotonin, -0.2),
        (Chemical.serotonin, -0.2),
        (Chemical.oxytocin, -0.2),
      ],
      Emotion.euphoria: [
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.dopamine, 0.2),
        (Chemical.endorphins, 0.2),
        (Chemical.endorphins, 0.2),
        (Chemical.endorphins, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.adrenaline, 0.2),
        (Chemical.oxytocin, 0.2),
        (Chemical.oxytocin, 0.2),
      ],
    };

    for (final entry in recipes.entries) {
      test(entry.key.name, () {
        final mood = HazeMood(clock: () => DateTime(2026, 7, 23, 12));
        for (final (chem, delta) in entry.value) {
          mood.dose(chem, delta);
        }
        expect(
          isMixSolved(mood.emotions(), entry.key),
          isTrue,
          reason:
              'recipe left ${entry.key.name} at '
              '${mood.emotions()[entry.key].toStringAsFixed(2)} '
              '(threshold ${mixThreshold(entry.key)})',
        );
      });
    }
  });
}
