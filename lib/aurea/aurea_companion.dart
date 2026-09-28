import 'dart:math' as math;

import 'aurea_model.dart';

/// Observations about a situation, not commands for Haze's face or chemistry.
/// These dimensions and their numeric mappings are authored Haze design.
class AureaAppraisal {
  static const dimensions = [
    'loss',
    'threat',
    'connection',
    'benefit',
    'uncertainty',
    'agency',
    'novelty',
  ];
  final Map<String, double> values;
  const AureaAppraisal._(this.values);

  factory AureaAppraisal.fromJson(Object? value) {
    final map = value is Map ? value : const {};
    return AureaAppraisal._(
      Map.unmodifiable({for (final key in dimensions) key: _bounded(map[key])}),
    );
  }
  static double _bounded(Object? value) {
    final n = value is num ? value.toDouble() : double.tryParse('$value');
    return n != null && n.isFinite ? n.clamp(0.0, 1.0) : 0;
  }

  double operator [](String key) => values[key] ?? 0;

  /// Conservative local cues when the optional language model is unavailable.
  /// Unrecognized messages stay neutral; this is not language understanding.
  factory AureaAppraisal.offline(String text) {
    final t = text.toLowerCase();
    bool has(
      String pattern,
    ) => RegExp(pattern, unicode: true).allMatches(t).any((match) {
      final prefix = t.substring(0, match.start);
      return !RegExp(
        r'\b(not|never|não|nunca|sem)\s+(?:(?:feeling|feel|estou|com)\s+)?$',
      ).hasMatch(prefix);
    });
    return AureaAppraisal.fromJson({
      'loss':
          has(
            r'\b(failed|lost|loss|sad|miss|perdi|perdeu|triste|falhei|saudade)\b',
          )
          ? .65
          : 0,
      'threat':
          has(r'\b(scared|afraid|worried|fear|medo|assustado|preocupad[oa])\b')
          ? .65
          : 0,
      'connection':
          has(r'\b(hug|thanks|thank|love|abraço|obrigad[oa]|carinho|amo)\b')
          ? .65
          : 0,
      'benefit': has(r'\b(won|passed|gift|ganhei|passei|presente|consegui)\b')
          ? .65
          : 0,
      'uncertainty':
          has(r"\b(unsure|confused|confuso|confusa)\b|não sei|not sure")
          ? .5
          : 0,
      'agency': has(r'\b(try|trying|tentar|tentando|consigo|consegui)\b')
          ? .6
          : .25,
    });
  }
}

/// Conversation continuity using the same ingredients, compound bottlenecks,
/// and expression mappings as the lab. Values guide the response without
/// erasing sadness or fear. No model output can set these levels directly.
class AureaCompanion {
  final AureaCatalog catalog;
  final DateTime Function() _now;
  late DateTime _updated;
  Map<String, double> _levels = {};
  double _surprise = 0;
  AureaAppraisal lastAppraisal = AureaAppraisal.fromJson(null);

  AureaCompanion(this.catalog, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now {
    _updated = _now();
  }

  double get _decay => math.exp(
    -math.max(0, _now().difference(_updated).inMilliseconds) / 180000,
  );
  Map<String, double> get levels {
    final decay = _decay;
    return {for (final e in _levels.entries) e.key: e.value * decay};
  }

  void observe(AureaAppraisal event) {
    final previous = levels;
    final loss = event['loss'];
    final threat = event['threat'];
    final connection = event['connection'];
    final benefit = event['benefit'];
    final care = math.max(loss, threat) * .8;
    final incoming = <String, double>{
      'sad': loss,
      'fear': threat,
      'cor': threat,
      'oxy': math.max(connection, loss * .6),
      'ap1': loss,
      'v1': care,
      'v6': threat * (.4 + .6 * event['agency']),
      'joy': benefit,
      'ap2': math.min(benefit, connection),
      'v2': math.max(benefit, connection) * .8,
    };
    _levels = {
      for (final id in catalog.ingredients.keys)
        id: ((previous[id] ?? 0) * .35 + (incoming[id] ?? 0) * .65).clamp(
          0.0,
          1.0,
        ),
    };
    _surprise = event['novelty'];
    lastAppraisal = event;
    _updated = _now();
  }

  Map<String, double> get compounds {
    final current = levels;
    return {
      for (final scenario in catalog.scenarios)
        scenario.id: (catalog.compound(scenario.id)['ingredients'] as List)
            .map((id) => current[id] ?? 0)
            .reduce(math.min),
    };
  }

  AureaExpression get expression {
    final current = levels;
    double channel(String name) => catalog.scenarios.fold<double>(0, (
      value,
      scenario,
    ) {
      final weights = scenario.channels[name] as Map<String, dynamic>? ?? {};
      final projected = weights.entries.fold<double>(
        0,
        (sum, e) => sum + (current[e.key] ?? 0) * (e.value as num).toDouble(),
      );
      return math.max(value, projected).clamp(0.0, 1.0);
    });
    return AureaExpression(
      warmth: .12 + channel('warmth') * .88,
      sorrow: channel('sorrow'),
      tension: math.max(
        channel('tension'),
        lastAppraisal['uncertainty'] * .2 * _decay,
      ),
      openness: .2 + channel('openness') * .8,
      activation: channel('activation'),
      steadiness: .3 + channel('steadiness') * .7,
      approach: channel('approach'),
      surprise: _surprise * _decay,
    );
  }

  Map<String, Object> get context => {
    'ingredients': levels,
    'compounds': compounds,
    'guidance':
        'Acknowledge loss gently; support agency without dismissing fear; receive kindness openly. Do not announce numeric levels.',
  };

  String fallback(String languageCode) {
    final pt = languageCode.toLowerCase().startsWith('pt');
    final a = lastAppraisal;
    if (a['loss'] > .2) {
      return pt
          ? 'Isso parece ter sido difícil. Quer me contar o que aconteceu?'
          : 'That sounds hard. Would you like to tell me what happened?';
    }
    if (a['threat'] > .2) {
      return pt
          ? 'Podemos ir com calma. Qual pequeno passo parece possível agora?'
          : 'We can take this slowly. What small step feels possible now?';
    }
    if (a['benefit'] > .2) {
      return pt
          ? 'Que bom! Qual foi a melhor parte?'
          : 'That sounds lovely! What was the best part?';
    }
    if (a['connection'] > .2) {
      return pt
          ? 'Obrigado pelo carinho. Estou aqui com você.'
          : 'Thank you for that kindness. I’m here with you.';
    }
    // A neutral appraisal has no useful canned reply. Let the face respond
    // quietly instead of repeating a generic request for more information.
    return '';
  }
}
