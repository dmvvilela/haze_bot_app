import 'dart:convert';
import 'dart:math' as math;

/// A versioned Aurea ingredient snapshot plus separately authored Haze scenarios.
/// This evaluates a demonstrator, not a biological or psychological measurement.
class AureaCatalog {
  final Map<String, dynamic> data;
  AureaCatalog._(this.data);

  factory AureaCatalog.decode(String source) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    if (data['schemaVersion'] != 1) {
      throw const FormatException('Unsupported Aurea schema');
    }
    final catalog = AureaCatalog._(data);
    final ids = <String>{};
    for (final scenario in catalog.scenarios) {
      if (!ids.add(scenario.id)) {
        throw FormatException('Duplicate scenario: ${scenario.id}');
      }
      final compound = catalog.compound(scenario.id);
      for (final id in (compound['ingredients'] as List).cast<String>()) {
        if (!catalog.ingredients.containsKey(id)) {
          throw FormatException('Unknown ingredient: $id');
        }
      }
      for (final mapping in scenario.channels.values) {
        for (final id in (mapping as Map).keys) {
          if (!catalog.ingredients.containsKey(id)) {
            throw FormatException('Unknown expression ingredient: $id');
          }
        }
      }
    }
    return catalog;
  }

  Map<String, dynamic> get ingredients =>
      data['ingredients'] as Map<String, dynamic>;
  List<AureaScenario> get scenarios => (data['scenarios'] as List)
      .map((s) => AureaScenario(s as Map<String, dynamic>))
      .toList(growable: false);
  Map<String, dynamic> compound(String id) => (data['compounds'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((c) => c['id'] == id);

  static String localized(dynamic text, String language) {
    final value = text as Map<String, dynamic>;
    return (value[language] ?? value['en']) as String;
  }
}

class AureaScenario {
  final Map<String, dynamic> data;
  const AureaScenario(this.data);
  String get id => data['id'] as String;
  Map<String, dynamic> get channels => data['channels'] as Map<String, dynamic>;
  String text(String key, String language) =>
      AureaCatalog.localized(data[key], language);
  String choice(String key, int index, String language) =>
      AureaCatalog.localized((data[key] as List)[index], language);
}

enum AureaPhase { notice, interpret, act }

/// Continuous controls shared by every compound. The renderer never branches
/// on a compound name or maps one to a fixed RobotExpression.
class AureaExpression {
  final double warmth, sorrow, tension, openness, activation, steadiness;
  final double approach, surprise;
  const AureaExpression({
    this.warmth = 0,
    this.sorrow = 0,
    this.tension = 0,
    this.openness = 0,
    this.activation = 0,
    this.steadiness = 0,
    this.approach = 0,
    this.surprise = 0,
  });
}

class AureaSnapshot {
  final Map<String, double> levels;
  final double strength;
  final AureaPhase phase;
  final AureaExpression expression;
  const AureaSnapshot(this.levels, this.strength, this.phase, this.expression);
}

class AureaSimulation {
  final AureaCatalog catalog;
  const AureaSimulation(this.catalog);

  /// Replay is pure: scrubbing, pausing and comparing do not accumulate history.
  /// Experience is an explicit counterfactual, scoped to this experiment.
  AureaSnapshot sample(
    AureaScenario scenario, {
    required double progress,
    required int interpretation,
    required bool practiced,
  }) {
    if (!progress.isFinite || interpretation < 0 || interpretation > 1) {
      throw ArgumentError('Invalid simulation input');
    }
    final p = progress.clamp(0.0, 1.0);
    final appraisalProgress = ((p - .2) / .35).clamp(0.0, 1.0);
    final actionProgress = ((p - .5) / .5).clamp(0.0, 1.0);
    final experience = practiced ? 1.0 : .48;
    final alignment = interpretation == 0 ? 1.0 : .18;
    final levels = <String, double>{};
    void add(dynamic map, double scale) {
      for (final entry in (map as Map<String, dynamic>).entries) {
        levels[entry.key] = ((entry.value as num).toDouble() * scale).clamp(
          0.0,
          1.0,
        );
      }
    }

    // The same event has the same base response in every counterfactual.
    // Fear is deliberately preserved as courage develops.
    add(scenario.data['base'], .65 + .35 * (p / .2).clamp(0.0, 1.0));
    add(
      (scenario.data['appraisals'] as List)[interpretation],
      appraisalProgress,
    );
    add(scenario.data['values'], experience * alignment * actionProgress);
    final required = (catalog.compound(scenario.id)['ingredients'] as List)
        .cast<String>();
    // Necessary ingredients are bottlenecks: a large base response cannot
    // compensate for a missing appraisal or value. This numeric rule is ours.
    final strength = required.map((id) => levels[id] ?? 0).reduce(math.min);
    double channel(String name) {
      final weights = scenario.channels[name] as Map<String, dynamic>? ?? {};
      return weights.entries
          .fold<double>(
            0,
            (sum, e) =>
                sum + (levels[e.key] ?? 0) * (e.value as num).toDouble(),
          )
          .clamp(0.0, 1.0);
    }

    final phase = p < .25
        ? AureaPhase.notice
        : p < .6
        ? AureaPhase.interpret
        : AureaPhase.act;
    return AureaSnapshot(
      Map.unmodifiable(levels),
      strength,
      phase,
      AureaExpression(
        warmth: channel('warmth'),
        sorrow: channel('sorrow'),
        tension: channel('tension'),
        openness: channel('openness'),
        activation: channel('activation'),
        steadiness: channel('steadiness'),
        approach: channel('approach'),
        surprise: (1 - appraisalProgress) * .65,
      ),
    );
  }
}
