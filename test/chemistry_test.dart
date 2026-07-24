import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/chemistry/chemistry.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/services/haze_mood.dart';

void main() {
  group('ChemicalState decay', () {
    test('one half-life halves the distance to baseline', () {
      final state = ChemicalState();
      state.set(Chemical.adrenaline, 0.9);
      final baseline = state.baseline(Chemical.adrenaline); // 0.1
      state.applyDecay(Chemical.adrenaline, state.halfLife(Chemical.adrenaline));
      expect(
        state.get(Chemical.adrenaline),
        closeTo(baseline + (0.9 - baseline) / 2, 1e-9),
      );
    });

    test('levels start at baseline and stay clamped to [0, 1]', () {
      final state = ChemicalState();
      for (final chem in Chemical.values) {
        expect(state.get(chem), state.baseline(chem));
      }
      state.set(Chemical.dopamine, 7);
      expect(state.get(Chemical.dopamine), 1.0);
      state.set(Chemical.dopamine, -3);
      expect(state.get(Chemical.dopamine), 0.0);
    });
  });

  group('NeurochemicalEngine', () {
    test('rest is a fixed point: an hour passes and nothing drifts', () {
      final engine = NeurochemicalEngine();
      engine.advance(3600);
      for (final chem in Chemical.values) {
        expect(
          engine.state.get(chem),
          closeTo(engine.state.baseline(chem), 1e-6),
          reason: '${chem.name} drifted at rest',
        );
      }
    });

    test('an impulse spikes, then decays back toward baseline', () {
      final engine = NeurochemicalEngine();
      engine.apply(const ChemicalImpulse(Chemical.adrenaline, 0.5));
      expect(engine.state.get(Chemical.adrenaline), closeTo(0.6, 1e-9));
      engine.advance(1800); // 10 adrenaline half-lives
      expect(engine.state.get(Chemical.adrenaline), closeTo(0.1, 0.01));
    });

    test('sustained impulses drip over their duration', () {
      final engine = NeurochemicalEngine();
      engine.apply(
        const ChemicalImpulse(Chemical.serotonin, 0.2, durationSeconds: 60),
      );
      expect(engine.state.get(Chemical.serotonin), 0.5); // nothing yet
      engine.advance(30);
      expect(engine.state.get(Chemical.serotonin), greaterThan(0.55));
      final atHalf = engine.state.get(Chemical.serotonin);
      engine.advance(30);
      expect(engine.state.get(Chemical.serotonin), greaterThan(atHalf));
    });

    test('same-source impulses saturate inside the window', () {
      final engine = NeurochemicalEngine();
      engine.apply(const ChemicalImpulse(Chemical.dopamine, 0.1, sourceId: 'x'));
      final afterFirst = engine.state.get(Chemical.dopamine);
      expect(afterFirst, closeTo(0.4, 1e-9));
      engine.apply(const ChemicalImpulse(Chemical.dopamine, 0.1, sourceId: 'x'));
      // Second dose is dampened: 0.1 / (1 + 0.3)
      expect(
        engine.state.get(Chemical.dopamine) - afterFirst,
        closeTo(0.1 / 1.3, 1e-9),
      );
    });

    test('high cortisol erodes serotonin (stress wears down wellbeing)', () {
      final engine = NeurochemicalEngine();
      engine.apply(const ChemicalImpulse(Chemical.cortisol, 0.6));
      engine.advance(600);
      expect(
        engine.state.get(Chemical.serotonin),
        lessThan(engine.state.baseline(Chemical.serotonin)),
      );
    });

    test('oxytocin relieves a cortisol spike faster than decay alone', () {
      final alone = NeurochemicalEngine();
      alone.apply(const ChemicalImpulse(Chemical.cortisol, 0.5));
      alone.advance(300);

      final comforted = NeurochemicalEngine();
      comforted.applyAll(const [
        ChemicalImpulse(Chemical.cortisol, 0.5),
        ChemicalImpulse(Chemical.oxytocin, 0.5),
      ]);
      comforted.advance(300);

      expect(
        comforted.state.get(Chemical.cortisol),
        lessThan(alone.state.get(Chemical.cortisol)),
      );
    });

    test('arousal cannot run away: adrenaline stays damped by the GABA floor',
        () {
      final engine = NeurochemicalEngine();
      engine.applyAll(const [
        ChemicalImpulse(Chemical.adrenaline, 0.9),
        ChemicalImpulse(Chemical.testosterone, 0.7),
      ]);
      engine.advance(3600);
      // The old constant-push formulation pinned adrenaline at 1.0 here.
      expect(engine.state.get(Chemical.adrenaline), lessThan(0.5));
      expect(
        engine.state.get(Chemical.gaba),
        greaterThanOrEqualTo(0.4 * 0.5 - 0.01), // never below the floor
      );
    });

    test('reseed keeps current levels but changes the resting nature', () {
      final engine = NeurochemicalEngine();
      engine.apply(const ChemicalImpulse(Chemical.dopamine, 0.3));
      final spiked = engine.state.get(Chemical.dopamine);
      engine.reseed(SeedChemistry.forPersonality('zen'));
      expect(engine.state.get(Chemical.dopamine), spiked);
      expect(engine.state.baseline(Chemical.gaba), 0.6);
    });
  });

  group('EmotionVector', () {
    test('at playful rest Haze is content, not blank', () {
      final engine =
          NeurochemicalEngine(seed: SeedChemistry.forPersonality('playful'));
      final emotions = EmotionVector.compute(engine.state);
      expect(emotions[Emotion.happiness], greaterThan(0.3));
      expect(emotions[Emotion.sadness], lessThan(0.15));
      expect(emotions[Emotion.anger], lessThan(0.35));
    });

    test('dopamine + adrenaline spike reads as excitement', () {
      final engine = NeurochemicalEngine();
      engine.applyAll(const [
        ChemicalImpulse(Chemical.dopamine, 0.5),
        ChemicalImpulse(Chemical.adrenaline, 0.6),
      ]);
      final emotions = EmotionVector.compute(engine.state);
      expect(emotions.dominant, Emotion.excitement);
    });

    test('cortisol up + reward chemicals down reads as sadness', () {
      final engine = NeurochemicalEngine();
      engine.applyAll(const [
        ChemicalImpulse(Chemical.cortisol, 0.5),
        ChemicalImpulse(Chemical.dopamine, -0.25),
        ChemicalImpulse(Chemical.serotonin, -0.4),
        ChemicalImpulse(Chemical.oxytocin, -0.15),
      ]);
      final emotions = EmotionVector.compute(engine.state);
      expect(emotions[Emotion.sadness], greaterThan(0.5));
    });

    test('personalities feel different at rest', () {
      final zen =
          NeurochemicalEngine(seed: SeedChemistry.forPersonality('zen'));
      final sarcastic =
          NeurochemicalEngine(seed: SeedChemistry.forPersonality('sarcastic'));
      expect(
        EmotionVector.compute(zen.state)[Emotion.calm],
        greaterThan(EmotionVector.compute(sarcastic.state)[Emotion.calm]),
      );
    });
  });

  group('HazeMood', () {
    test('events move the chemistry the right way', () {
      var now = DateTime(2026, 7, 23, 12);
      final mood = HazeMood(clock: () => now);
      final restingOxytocin = mood.level(Chemical.oxytocin);
      mood.cuddled();
      expect(mood.level(Chemical.oxytocin), greaterThan(restingOxytocin));

      mood.shaken();
      expect(mood.level(Chemical.adrenaline), greaterThan(0.3));

      // Twenty minutes later the adrenaline flash is mostly gone, the
      // oxytocin warmth much less so.
      now = now.add(const Duration(minutes: 20));
      expect(mood.level(Chemical.adrenaline), lessThan(0.15));
      expect(mood.level(Chemical.oxytocin), greaterThan(restingOxytocin + 0.1));
    });

    test('expression holds suppress the mood face, then expire', () {
      var now = DateTime(2026, 7, 23, 12);
      final mood = HazeMood(clock: () => now);
      expect(mood.moodDriven, isTrue);
      mood.holdExpression();
      expect(mood.moodDriven, isFalse);
      now = now.add(const Duration(seconds: 8));
      expect(mood.moodDriven, isTrue);
      mood.pinned = true;
      expect(mood.moodDriven, isFalse);
    });

    test('acting a face nudges its chemistry', () {
      final mood = HazeMood(clock: () => DateTime(2026, 7, 23, 12));
      final before = mood.level(Chemical.testosterone);
      mood.reactedTo(RobotExpression.angry);
      expect(mood.level(Chemical.testosterone), greaterThan(before));
    });

    test('days of suspension settle to baseline via the analytic fast path',
        () {
      var now = DateTime(2026, 7, 23, 12);
      final mood = HazeMood(clock: () => now);
      mood.tickled();
      mood.shaken();
      now = now.add(const Duration(days: 2));
      for (final chem in Chemical.values) {
        expect(
          mood.level(chem),
          closeTo(mood.baselines()[chem]!, 0.01),
          reason: '${chem.name} not settled after two days away',
        );
      }
    });

    test('restoring a week-old snapshot lands at baseline', () {
      var now = DateTime(2026, 7, 23, 12);
      final mood = HazeMood(clock: () => now);
      mood.cuddled();
      final saved = mood.toJson();
      now = now.add(const Duration(days: 7));
      final restored = HazeMood(clock: () => now)..restore(saved);
      expect(restored.level(Chemical.oxytocin), closeTo(0.2, 0.01));
    });

    test('persistence roundtrip decays by the time spent away', () {
      var now = DateTime(2026, 7, 23, 12);
      final mood = HazeMood(clock: () => now);
      mood.tickled();
      final saved = mood.toJson();
      final endorphinsAtSave = mood.level(Chemical.endorphins);

      // Reopen the app 30 minutes (one endorphins half-life) later.
      now = now.add(const Duration(minutes: 30));
      final restored = HazeMood(clock: () => now)..restore(saved);
      final baseline = 0.2;
      expect(
        restored.level(Chemical.endorphins),
        closeTo(baseline + (endorphinsAtSave - baseline) / 2, 0.02),
      );
    });
  });
}
