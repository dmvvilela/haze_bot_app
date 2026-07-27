import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/chemistry/chemistry.dart';
import 'package:haze_bot_app/models/robot_config.dart';
import 'package:haze_bot_app/services/haze_brain.dart';

void main() {
  group('HazeBrain chemistry response parsing', () {
    final brain = HazeBrain();

    test('reads a Kindalive-style reply and chemical impulses', () {
      final reply = brain.parseResponseForTest('''
{"emotion":"excited","say":"Jackpot! My circuits are buzzing.","impulses":[
  {"chemical":"dopamine","delta":0.45},
  {"chemical":"adrenaline","delta":0.35}
]}''');

      expect(reply.emotion, RobotExpression.excited);
      expect(reply.say, 'Jackpot! My circuits are buzzing.');
      expect(reply.impulses, hasLength(2));
      expect(reply.impulses.first.chemical, Chemical.dopamine);
      expect(reply.impulses.first.delta, 0.45);
      expect(reply.impulses.last.chemical, Chemical.adrenaline);
    });

    test('rejects unknown chemicals and clamps unsafe values', () {
      final reply = brain.parseResponseForTest('''
{"emotion":"scared","say":"Eep!","impulses":[
  {"chemical":"adrenaline","delta":9,"duration_seconds":900},
  {"chemical":"magic","delta":0.5},
  {"chemical":"gaba","delta":"-0.08"}
]}''');

      expect(reply.impulses, hasLength(2));
      expect(reply.impulses.first.delta, 0.5);
      expect(reply.impulses.first.durationSeconds, 300);
      expect(reply.impulses.last.chemical, Chemical.gaba);
      expect(reply.impulses.last.delta, -0.08);
    });

    test('keeps the legacy emotion-tag fallback working', () {
      final reply = brain.parseResponseForTest(
        '[love] I am right here with you.',
      );

      expect(reply.emotion, RobotExpression.love);
      expect(reply.say, 'I am right here with you.');
      expect(reply.impulses, isEmpty);
    });
  });
}
