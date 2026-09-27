import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/aurea/aurea_companion.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';
import 'package:haze_bot_app/services/haze_brain.dart';

void main() {
  AureaCompanion companion() => AureaCompanion(
    AureaCatalog.decode(File('assets/aurea/prototype.json').readAsStringSync()),
  );
  test(
    'appraisals bound finite evidence and ignore emotion/chemical commands',
    () {
      final a = AureaAppraisal.fromJson({
        'loss': 9,
        'threat': -2,
        'connection': double.nan,
        'benefit': double.infinity,
        'emotion': 'happy',
        'impulses': [
          {'chemical': 'dopamine', 'delta': 1},
        ],
      });
      expect(a['loss'], 1);
      expect(a['threat'], 0);
      expect(a['connection'], 0);
      expect(a['benefit'], 0);
      expect(a.values.length, AureaAppraisal.dimensions.length);
    },
  );
  test(
    'brain interprets first and writes using the app-computed state',
    () async {
      final prompts = <String>[];
      final brain = HazeBrain(
        generate: (prompt) async {
          prompts.add(prompt);
          return prompts.length == 1
              ? '{"loss":0.8,"agency":0.4}'
              : '{"say":"That mattered to you. I’m listening.","emotion":"excited"}';
        },
      );
      final body = companion();
      body.observe(await brain.appraise('I lost something important.'));
      final line = await brain.respond(
        userText: 'I lost something important.',
        companion: body,
      );
      expect(body.expression.sorrow, greaterThan(.4));
      expect(body.compounds['compassion'], greaterThan(0));
      expect(line, contains('I’m listening'));
      expect(prompts.last, contains('compassion'));
      expect(prompts.last, contains('ingredients'));
      expect(body.expression.sorrow, greaterThan(.4));
    },
  );
  test('malformed generation falls back without displaying JSON', () async {
    final brain = HazeBrain(generate: (_) async => '{"say":');
    final body = companion();
    body.observe(await brain.appraise('Estou com medo.'));
    expect(body.expression.tension, greaterThan(0));
    expect(
      await brain.respond(
        userText: 'Estou com medo.',
        companion: body,
        languageCode: 'pt',
      ),
      contains('calma'),
    );
  });
  test(
    'offline replies acknowledge the situation instead of a happy preset',
    () async {
      final brain = HazeBrain();
      final body = companion()
        ..observe(await brain.appraise('I failed my exam.'));
      expect(
        await brain.respond(userText: 'I failed my exam.', companion: body),
        contains('hard'),
      );
    },
  );
  test('disabling AI bypasses even an already loaded model', () async {
    var calls = 0;
    final brain = HazeBrain(
      generate: (_) async {
        calls++;
        return '{}';
      },
    );
    final body = companion();
    body.observe(await brain.appraise('I failed.', useModel: false));
    expect(body.expression.sorrow, greaterThan(0));
    expect(
      await brain.respond(
        userText: 'I failed.',
        companion: body,
        useModel: false,
      ),
      contains('hard'),
    );
    expect(calls, 0);
  });
  test(
    'offline cues respect simple negation and preserve timer replies',
    () async {
      expect(AureaAppraisal.offline('I am not sad.')['loss'], 0);
      expect(AureaAppraisal.offline('Não estou triste.')['loss'], 0);
      final line = await HazeBrain().respond(
        userText: 'Timer finished.',
        companion: companion(),
        builtInReply: 'Your timer is done.',
      );
      expect(line, 'Your timer is done.');
    },
  );
  test('compound ingredients retain fear while supporting agency', () {
    final body = companion()
      ..observe(AureaAppraisal.fromJson({'threat': .8, 'agency': .9}));
    expect(body.compounds['courage'], greaterThan(0));
    expect(body.expression.tension, greaterThan(0));
    expect(body.expression.steadiness, greaterThan(.3));
  });
  test('state carries between messages and settles with time', () {
    var now = DateTime(2026);
    final body = AureaCompanion(companion().catalog, clock: () => now);
    body.observe(AureaAppraisal.fromJson({'loss': 1}));
    final first = body.expression.sorrow;
    body.observe(AureaAppraisal.fromJson({'connection': 1}));
    expect(body.expression.sorrow, greaterThan(0));
    expect(body.expression.sorrow, lessThan(first));
    final second = body.expression.sorrow;
    now = now.add(const Duration(minutes: 10));
    expect(body.expression.sorrow, lessThan(second * .1));
  });
}
