import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/chemistry/chemistry.dart';
import 'package:haze_bot_app/chemistry/lab_reference.dart';
import 'package:haze_bot_app/services/haze_mood.dart';

void main() {
  test(
    'references have distinct intended dominant moods for every personality',
    () {
      for (final personality in [
        'playful',
        'sarcastic',
        'sleepy',
        'zen',
        'meditative',
      ]) {
        final mood = HazeMood()
          ..setPersonality(personality)
          ..setPaused(true);
        for (final reference in LabReference.values) {
          mood.loadLabLevels(reference.levels);
          expect(
            mood.emotions().dominant,
            reference.emotion,
            reason: '$personality / ${reference.name}',
          );
        }
      }
    },
  );

  test('paused time is discarded and live time resumes normally', () {
    var now = DateTime(2026);
    final mood = HazeMood(clock: () => now)..setPaused(true);
    mood.loadLabLevels(LabReference.excited.levels);
    final initial = mood.levels();
    now = now.add(const Duration(hours: 2));
    expect(mood.levels(), initial);
    mood.setPaused(false);
    expect(mood.levels(), initial);
    now = now.add(const Duration(minutes: 1));
    expect(mood.levels(), isNot(initial));
  });

  test('guided changes affect one chemical and restore repeats exactly', () {
    final mood = HazeMood()
      ..setPaused(true)
      ..labControlled = true;
    mood.loadLabLevels(LabReference.content.levels);
    final before = mood.levels();
    final emotionBefore = mood.emotions()[Emotion.happiness];
    mood.shaken();
    expect(mood.levels(), before);
    mood.adjustLabChemical(Chemical.dopamine, 0.2);
    expect(
      mood.emotions()[Emotion.happiness] - emotionBefore,
      closeTo(0.07, 1e-9),
    );
    for (final chemical in Chemical.values.where(
      (c) => c != Chemical.dopamine,
    )) {
      expect(mood.level(chemical), before[chemical]);
    }
    final after = mood.levels();
    mood.loadLabLevels(LabReference.content.levels);
    expect(mood.levels(), before);
    mood.adjustLabChemical(Chemical.dopamine, 0.2);
    expect(mood.levels(), after);
  });
}
