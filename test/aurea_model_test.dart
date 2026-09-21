import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haze_bot_app/aurea/aurea_model.dart';

void main() {
  final catalog = AureaCatalog.decode(
    File('assets/aurea/prototype.json').readAsStringSync(),
  );
  final simulation = AureaSimulation(catalog);
  for (final scenario in catalog.scenarios) {
    test('${scenario.id}: meaning changes response, not the event', () {
      final open = simulation.sample(
        scenario,
        progress: 1,
        interpretation: 0,
        practiced: true,
      );
      final closed = simulation.sample(
        scenario,
        progress: 1,
        interpretation: 1,
        practiced: true,
      );
      for (final id in (scenario.data['base'] as Map).keys) {
        expect(closed.levels[id], open.levels[id]);
      }
      expect(open.strength, greaterThan(.6));
      expect(closed.strength, lessThan(.2));
      expect(open.expression.approach, greaterThan(closed.expression.approach));
    });
    test(
      '${scenario.id}: practice develops steadiness without deleting the feeling',
      () {
        final first = simulation.sample(
          scenario,
          progress: 1,
          interpretation: 0,
          practiced: false,
        );
        final practiced = simulation.sample(
          scenario,
          progress: 1,
          interpretation: 0,
          practiced: true,
        );
        expect(
          practiced.expression.steadiness,
          greaterThan(first.expression.steadiness),
        );
        for (final id in (scenario.data['base'] as Map).keys) {
          expect(practiced.levels[id], first.levels[id]);
        }
        final replay = simulation.sample(
          scenario,
          progress: 1,
          interpretation: 0,
          practiced: false,
        );
        expect(replay.levels, first.levels);
      },
    );
    test('${scenario.id}: every necessary ingredient matters', () {
      final required = (catalog.compound(scenario.id)['ingredients'] as List)
          .cast<String>();
      for (final missing in required) {
        final data = {...scenario.data};
        for (final name in ['base', 'values']) {
          data[name] = <String, dynamic>{
            ...scenario.data[name] as Map<String, dynamic>,
          }..remove(missing);
        }
        data['appraisals'] = [
          for (final appraisal in scenario.data['appraisals'] as List)
            <String, dynamic>{...appraisal as Map<String, dynamic>}
              ..remove(missing),
        ];
        final result = simulation.sample(
          AureaScenario(data),
          progress: 1,
          interpretation: 0,
          practiced: true,
        );
        expect(result.strength, 0, reason: missing);
      }
    });
    test('${scenario.id}: bounded timeline, phased assembly and replay', () {
      final notice = simulation.sample(
        scenario,
        progress: 0,
        interpretation: 0,
        practiced: true,
      );
      expect(notice.phase, AureaPhase.notice);
      expect(notice.strength, 0);
      expect(
        simulation
            .sample(scenario, progress: .4, interpretation: 0, practiced: true)
            .phase,
        AureaPhase.interpret,
      );
      for (var i = 0; i <= 100; i++) {
        final sample = simulation.sample(
          scenario,
          progress: i / 100,
          interpretation: 0,
          practiced: true,
        );
        expect(
          sample.levels.values.every((v) => v.isFinite && v >= 0 && v <= 1),
          isTrue,
        );
      }
      expect(
        () => simulation.sample(
          scenario,
          progress: double.nan,
          interpretation: 0,
          practiced: true,
        ),
        throwsArgumentError,
      );
    });
  }
  test('courage retains fear while steadiness and approach develop', () {
    final courage = catalog.scenarios.firstWhere((s) => s.id == 'courage');
    final before = simulation.sample(
      courage,
      progress: .25,
      interpretation: 0,
      practiced: true,
    );
    final after = simulation.sample(
      courage,
      progress: 1,
      interpretation: 0,
      practiced: true,
    );
    expect(after.levels['fear'], before.levels['fear']);
    expect(after.expression.tension, before.expression.tension);
    expect(
      after.expression.steadiness,
      greaterThan(before.expression.steadiness),
    );
  });
}
