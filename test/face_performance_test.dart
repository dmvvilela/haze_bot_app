import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/widgets/face_performance.dart';

void main() {
  void tick(
    FacePerformance face,
    FaceActivity activity, {
    double? level,
    int frames = 30,
    bool reduced = false,
  }) {
    for (var i = 0; i < frames; i++) {
      face.advance(
        dt: 1 / 60,
        activity: activity,
        level: level,
        reducedMotion: reduced,
      );
    }
  }

  test('a pause closes the mouth while the utterance remains active', () {
    final face = FacePerformance();
    tick(face, FaceActivity.speaking, level: .8);
    expect(face.mouth, greaterThan(.7));
    tick(face, FaceActivity.speaking, level: 0, frames: 18);
    expect(face.mouth, 0);
    tick(face, FaceActivity.speaking, level: 0, frames: 120);
    expect(face.mouth, 0);
    tick(face, FaceActivity.speaking, level: .6);
    expect(face.mouth, greaterThan(.5));
  });

  test(
    'only an unknown meter uses the fallback; invalid samples stay silent',
    () {
      final face = FacePerformance();
      tick(face, FaceActivity.speaking);
      expect(face.mouth, greaterThan(.1));
      tick(face, FaceActivity.speaking, level: double.nan);
      expect(face.mouth, 0);
      tick(face, FaceActivity.speaking, level: -.1);
      expect(face.mouth, 0);
    },
  );

  test(
    'interrupting speech listens without a finishing nod or talking mouth',
    () {
      final face = FacePerformance();
      tick(face, FaceActivity.speaking, level: .8);
      tick(face, FaceActivity.listening, level: .9);
      expect(face.mouth, 0);
      expect(face.attention, greaterThan(.9));
      expect(face.nod, lessThan(0));
      expect(face.tilt, greaterThan(0));
      tick(face, FaceActivity.thinking);
      expect(face.tilt, lessThan(0));
      expect(face.asymmetry, greaterThan(.9));
    },
  );

  test('finishing gesture settles and does not replay while idle', () {
    final face = FacePerformance();
    tick(face, FaceActivity.speaking, level: .8);
    tick(face, FaceActivity.resting, frames: 20);
    expect(face.nod, greaterThan(.5));
    tick(face, FaceActivity.resting, frames: 180);
    expect(face.nod.abs(), lessThan(.001));
    expect(face.mouth, 0);
    expect(face.emphasis, lessThan(.001));
  });

  test(
    'reduce motion suppresses gestures but keeps audio-driven articulation',
    () {
      final face = FacePerformance();
      for (final activity in FaceActivity.values) {
        tick(face, activity, level: .8, reduced: true);
        expect(face.nod, 0);
        expect(face.tilt, 0);
        expect(face.emphasis, 0);
      }
      expect(face.mouth, greaterThan(.7));
    },
  );
}
