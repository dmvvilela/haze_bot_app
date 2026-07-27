import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../chemistry/chemistry.dart';
import '../models/robot_config.dart';

/// What Haze decides to say plus the simulated body response it wants to have.
///
/// [emotion] remains as a safe fallback for canned/invalid model output. When
/// [impulses] is populated, chemistry—not the tag—is the source of truth for
/// the face.
class HazeReply {
  final RobotExpression emotion;
  final String say;
  final List<ChemicalImpulse> impulses;

  const HazeReply(this.emotion, this.say, {this.impulses = const []});
}

/// Lifecycle of the on-device model, surfaced to the UI.
enum BrainStatus { idle, downloading, preparing, ready, unavailable }

/// Whether the user has agreed to download + use Haze's on-device AI brain.
/// `unknown` until they're asked; the model download only ever starts on
/// `granted`. `declined` keeps Haze on its built-in canned lines.
enum AiConsent { unknown, granted, declined }

/// Haze's voice. Only swaps the system-prompt flavor; the format rules and the
/// 8 faces stay identical across personalities.
enum HazePersonality { playful, sarcastic, sleepy, zen, meditative }

extension HazePersonalityX on HazePersonality {
  String get displayName => switch (this) {
    HazePersonality.playful => 'Playful',
    HazePersonality.sarcastic => 'Sarcastic',
    HazePersonality.sleepy => 'Sleepy',
    HazePersonality.zen => 'Zen',
    HazePersonality.meditative => 'Meditative',
  };

  /// One line injected into the system prompt to set Haze's tone.
  String get voice => switch (this) {
    HazePersonality.playful =>
      'You are playful, bubbly and upbeat, full of cute robot/tech-flavored humor.',
    HazePersonality.sarcastic =>
      'You are dry and lovingly sarcastic — you tease and quip, but you clearly care.',
    HazePersonality.sleepy =>
      'You are drowsy and cozy, speaking softly and slowly like you are half asleep.',
    HazePersonality.zen =>
      'You are calm, gentle and mindful, like a tiny robot monk who soothes and reassures.',
    HazePersonality.meditative =>
      'You are soft, slow and meditative, helping the user breathe, settle and rest with sleepy little zzz energy.',
  };
}

/// Haze's on-device "brain", backed by `flutter_gemma` (Gemma 3 1B, local).
///
/// No server and no API key at runtime — the model file is downloaded once on
/// first use and then runs fully offline. Whenever the model is unavailable
/// (not downloaded yet, low-end device, parse failure) it falls back to canned
/// lines, so Haze always answers and can never regress below the old behaviour.
class HazeBrain {
  HazeBrain({String? modelUrl, String? huggingFaceToken})
    : _modelUrl = modelUrl,
      _hfToken = huggingFaceToken;

  // --- Configuration (read from .env at runtime) -------------------------
  //
  // Gemma is license-gated on Hugging Face, so the first-run download needs a
  // free HF token in .env (accept the Gemma license once), OR set HAZE_MODEL_URL
  // in .env to your own static copy of the .task file (no token needed).
  static const _fallbackModelUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task';

  final String? _modelUrl;
  final String? _hfToken;

  String get _effectiveModelUrl =>
      _modelUrl ?? _fromEnv('HAZE_MODEL_URL') ?? _fallbackModelUrl;
  String get _effectiveToken => _hfToken ?? _fromEnv('HUGGINGFACE_TOKEN') ?? '';

  static String? _fromEnv(String key) {
    try {
      return dotenv.isInitialized ? dotenv.maybeGet(key) : null;
    } catch (_) {
      return null;
    }
  }

  InferenceModel? _model;
  InferenceChat? _chat;
  Future<void>? _readyFuture;

  BrainStatus status = BrainStatus.idle;
  int downloadProgress = 0; // 0..100

  HazePersonality _personality = HazePersonality.playful;
  int _turns = 0;
  static const int _maxTurns = 8;

  bool get isReady => status == BrainStatus.ready && _chat != null;

  /// Ensure the model is downloaded and loaded. Safe to call repeatedly:
  /// the work runs once and concurrent callers await the same future.
  Future<void> ensureReady({void Function(BrainStatus, int)? onUpdate}) {
    return _readyFuture ??= _prepare(onUpdate).catchError((Object e) {
      debugPrint('HazeBrain: failed to prepare model: $e');
      status = BrainStatus.unavailable;
      onUpdate?.call(status, downloadProgress);
      _readyFuture = null; // allow a later retry
    });
  }

  Future<void> _prepare(void Function(BrainStatus, int)? onUpdate) async {
    // 1) Make sure the model file is installed and active. install() is
    //    idempotent: it skips the download if the file is already present, and
    //    it repairs the "installed but not active" case before loading.
    final hadActiveModel = FlutterGemma.hasActiveModel();
    if (!hadActiveModel) {
      status = BrainStatus.downloading;
      onUpdate?.call(status, 0);
    }
    final token = _effectiveToken;
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromNetwork(_effectiveModelUrl, token: token.isEmpty ? null : token)
        .withProgress((p) {
          downloadProgress = p;
          onUpdate?.call(BrainStatus.downloading, p);
        })
        .install();

    // 2) Load the model into memory and open one chat carrying Haze's persona.
    status = BrainStatus.preparing;
    downloadProgress = 100;
    onUpdate?.call(status, 100);

    _model = await FlutterGemma.getActiveModel(maxTokens: 1024);
    _chat = await _model!.createChat(
      systemInstruction: _buildSystemInstruction(),
      temperature: 1.0,
      topK: 40,
      topP: 0.95,
      randomSeed: Random().nextInt(1 << 31),
      modelType: ModelType.gemmaIt,
    );

    status = BrainStatus.ready;
    onUpdate?.call(status, 100);
  }

  /// Core entry point: given something that just happened (the user's message,
  /// or a framed situation like a finished timer), return Haze's `{emotion, say}`.
  Future<HazeReply> respond({
    required String userText,
    String languageCode = 'en',
    RobotExpression fallbackEmotion = RobotExpression.happy,
    Map<Chemical, double> currentChemistry = const {},
  }) async {
    if (!isReady) return _cannedReply(fallbackEmotion, languageCode);

    try {
      // Keep context from growing without bound — it would overflow maxTokens
      // and degrade. Wipe Haze's short-term memory every few turns.
      if (_turns >= _maxTurns) await resetConversation();

      final lang = languageCode.toLowerCase().startsWith('pt')
          ? 'Brazilian Portuguese'
          : 'English';
      final chemistry = currentChemistry.isEmpty
          ? ''
          : '\nCurrent simulated chemistry (0 to 1): '
                '${currentChemistry.entries.map((e) => '${e.key.name}=${e.value.toStringAsFixed(2)}').join(', ')}.';
      await _chat!.addQueryChunk(
        Message.text(
          text:
              'IMPORTANT: Reply only in $lang. Do not switch languages. '
              'If asked for a joke, riddle, or question-answer bit, include '
              'the full punchline in this same reply.'
              '$chemistry\nWhat the owner told Haze: $userText',
          isUser: true,
        ),
      );
      final response = await _chat!.generateChatResponse();
      _turns++;
      final raw = response is TextResponse
          ? response.token
          : response.toString();
      final parsed = _parse(raw, fallbackEmotion, languageCode);
      if (_isJokeRequest(userText) && _looksLikeSetupOnly(parsed.say)) {
        return HazeReply(
          RobotExpression.winking,
          _completeJoke(languageCode),
          impulses: parsed.impulses,
        );
      }
      return parsed;
    } catch (e) {
      debugPrint('HazeBrain: generation failed: $e');
      return _cannedReply(fallbackEmotion, languageCode);
    }
  }

  /// Forget the running conversation but keep the model loaded.
  Future<void> resetConversation() async {
    if (_model == null) return;
    _turns = 0;
    try {
      await _chat?.session.close();
    } catch (_) {}
    _chat = await _model!.createChat(
      systemInstruction: _buildSystemInstruction(),
      temperature: 1.0,
      topK: 40,
      topP: 0.95,
      randomSeed: Random().nextInt(1 << 31),
      modelType: ModelType.gemmaIt,
    );
  }

  /// Change Haze's voice. Rebuilds the chat so the new persona takes effect and
  /// clears short-term memory. No-op if the model isn't loaded yet — the new
  /// voice applies when the chat is first created.
  Future<void> setPersonality(HazePersonality personality) async {
    if (_personality == personality) return;
    _personality = personality;
    if (_model != null) await resetConversation();
  }

  Future<void> dispose() async {
    try {
      await _chat?.session.close();
    } catch (_) {}
    try {
      await _model?.close();
    } catch (_) {}
  }

  // --- Parsing -----------------------------------------------------------

  /// Tolerant parser: the preferred format is one JSON object, but the old
  /// `[emotion] line` contract remains accepted for model/fallback resilience.
  HazeReply _parse(
    String raw,
    RobotExpression fallbackEmotion,
    String languageCode,
  ) {
    var text = raw.trim();
    RobotExpression? emotion;
    var impulses = const <ChemicalImpulse>[];

    // 1) Preferred format:
    // {"emotion":"excited","say":"...","impulses":[{...}]}
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start != -1 && end > start) {
      try {
        final map =
            jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
        emotion = _emotionFrom(map['emotion']?.toString());
        final say = (map['say'] ?? map['text'] ?? '').toString().trim();
        if (say.isNotEmpty) text = say;
        impulses = _parseImpulses(map['impulses']);
      } catch (_) {
        // Fall through to the legacy tag/plain-text parser.
      }
    }

    // 2) Legacy format: a [tag] somewhere in the reply.
    if (emotion == null) {
      final tag = RegExp(r'\[\s*([a-zA-Z]+)\s*\]').firstMatch(text);
      if (tag != null) {
        final found = _emotionFrom(tag.group(1));
        if (found != null) {
          emotion = found;
          text = text.replaceFirst(tag.group(0)!, '').trim();
        }
      }
    }

    // 3) Last resort: infer the mood from keywords in Haze's own words, so the
    //    face still varies even when the model just returns plain prose.
    emotion ??= _guessEmotion(text);

    // 4) Strip any leftover markdown.
    text = text.replaceAll(RegExp(r'[`*_#]'), '').trim();

    if (text.isEmpty) {
      return _cannedReply(emotion ?? fallbackEmotion, languageCode);
    }
    return HazeReply(emotion ?? fallbackEmotion, text, impulses: impulses);
  }

  List<ChemicalImpulse> _parseImpulses(dynamic value) {
    if (value is! List) return const [];
    final parsed = <ChemicalImpulse>[];
    for (final item in value.take(Chemical.values.length)) {
      if (item is! Map) continue;
      final chemical = _chemicalFrom(item['chemical']?.toString());
      final delta = _number(item['delta']);
      if (chemical == null || delta == null || delta.abs() < 0.001) continue;
      final duration = (_number(item['duration_seconds']) ?? 0).clamp(
        0.0,
        300.0,
      );
      parsed.add(
        ChemicalImpulse(
          chemical,
          delta.clamp(-0.5, 0.5),
          durationSeconds: duration,
          sourceId: 'brain-${chemical.name}',
        ),
      );
    }
    return List.unmodifiable(parsed);
  }

  Chemical? _chemicalFrom(String? value) {
    final key = value?.trim().toLowerCase();
    for (final chemical in Chemical.values) {
      if (chemical.name == key) return chemical;
    }
    return null;
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  @visibleForTesting
  HazeReply parseResponseForTest(
    String raw, {
    RobotExpression fallbackEmotion = RobotExpression.happy,
    String languageCode = 'en',
  }) => _parse(raw, fallbackEmotion, languageCode);

  RobotExpression? _emotionFrom(String? s) {
    if (s == null) return null;
    final key = s.toLowerCase().trim();
    for (final e in RobotExpression.values) {
      if (e.name == key) return e;
    }
    return null;
  }

  /// Cheap on-device keyword heuristic — only used when the model emits neither
  /// a [tag] nor JSON. More specific moods are checked before generic "happy".
  RobotExpression? _guessEmotion(String text) {
    final t = text.toLowerCase();
    const hints = <RobotExpression, List<String>>{
      RobotExpression.sleepy: [
        'sleep',
        'tired',
        'yawn',
        'nap',
        'zzz',
        'drowsy',
        'powering down',
        'battery is low',
        'three percent',
      ],
      RobotExpression.love: [
        'love',
        'adore',
        'heart',
        'here with you',
        'care about',
        'sweet',
      ],
      RobotExpression.angry: [
        'angry',
        'grr',
        'furious',
        'unfair',
        'steam',
        'overheat',
      ],
      RobotExpression.confused: [
        'confus',
        'not sure',
        'error 404',
        "don't understand",
        'tangled',
      ],
      RobotExpression.surprised: [
        'whoa',
        'surpris',
        'gasp',
        "didn't see that",
        'no way',
      ],
      RobotExpression.winking: ['wink', 'charm', 'between us'],
      RobotExpression.sad: [
        'sad',
        'cry',
        'tear',
        'lonely',
        'miss you',
        'heavy',
        'rain cloud',
      ],
      RobotExpression.scared: [
        'scared',
        'afraid',
        'fear',
        'spooky',
        'yikes',
        'eep',
        'terrified',
      ],
      RobotExpression.excited: [
        'excit',
        'amazing',
        'awesome',
        'yay',
        'incredible',
        "let's go",
        'lets go',
        'victory',
        'buzzing',
      ],
      RobotExpression.happy: ['happy', 'glad', 'joy', 'great', 'wonderful'],
    };
    for (final entry in hints.entries) {
      for (final kw in entry.value) {
        if (t.contains(kw)) return entry.key;
      }
    }
    return null;
  }

  HazeReply _cannedReply(RobotExpression emotion, String languageCode) {
    final canned = languageCode.toLowerCase().startsWith('pt')
        ? _cannedPt
        : _cannedEn;
    return HazeReply(
      emotion,
      canned[emotion] ?? canned[RobotExpression.happy]!,
    );
  }

  bool _isJokeRequest(String text) {
    final t = text.toLowerCase();
    return t.contains('joke') ||
        t.contains('piada') ||
        t.contains('engraçad') ||
        t.contains('me faça rir') ||
        t.contains('make me laugh');
  }

  bool _looksLikeSetupOnly(String text) {
    final trimmed = text.trim();
    if (trimmed.endsWith('?')) return true;
    final lower = trimmed.toLowerCase();
    return lower.startsWith('por que ') ||
        lower.startsWith('o que ') ||
        lower.startsWith('why ') ||
        lower.startsWith('what ');
  }

  String _completeJoke(String languageCode) {
    if (languageCode.toLowerCase().startsWith('pt')) {
      return 'Por que o robo levou uma escada para o trabalho? Porque queria subir de versao.';
    }
    return 'Why did the robot bring a ladder to work? Because it wanted to upgrade itself.';
  }

  // --- Persona + offline fallback lines ---------------------------------

  String _buildSystemInstruction() =>
      '''
You are Haze, a tiny pocket robot companion living on the user's phone screen.
${_personality.voice}

Interpret what Haze's owner says as an event happening to Haze. Return ONLY one valid JSON object:
{"emotion":"excited","say":"Short in-character reply.","impulses":[{"chemical":"dopamine","delta":0.30},{"chemical":"adrenaline","delta":0.25}]}

Chemistry rules:
- Chemicals: dopamine (reward/motivation), serotonin (stable wellbeing), oxytocin (bonding/trust), testosterone (drive/competition), cortisol (stress), adrenaline (arousal/startle), endorphins (sustained pleasure/relief), gaba (calm/inhibition).
- `delta` changes the current level; it is NOT a target level. Use -0.50 to 0.50.
- Small everyday moment: 0.05–0.12. Meaningful event: 0.15–0.30. Huge rare event: 0.35–0.50.
- Use 0 to 4 impulses normally, never more than 8. Negative deltas are allowed.
- Optional `duration_seconds` is 0 to 300. Omit it for sudden events; use it only for gradual ambient effects.
- Emotions emerge from the combined chemistry. Do not force every event into one chemical.
- This is Haze's playful simulated body, never medical advice or a claim about a human brain.

Reply rules:
- `emotion` must be exactly one of: happy, surprised, sleepy, excited, confused, love, angry, winking, sad, scared.
- `say` is at most 2 short sentences, easy to read aloud.
- If the user asks for a joke, include the setup and punchline in the same reply.
- Never end with only a setup question or cliffhanger.
- If the user gives a language instruction, obey it exactly for the whole reply.
- No emojis or markdown.
- Stay in character as Haze. Be kind and family-friendly.

Examples:
Owner: You won the lottery!
Haze: {"emotion":"excited","say":"Jackpot! My circuits can barely contain this much victory.","impulses":[{"chemical":"dopamine","delta":0.45},{"chemical":"adrenaline","delta":0.35},{"chemical":"endorphins","delta":0.25}]}
Owner: I am here with you. Big hug.
Haze: {"emotion":"love","say":"Oh, that warmed every little circuit.","impulses":[{"chemical":"oxytocin","delta":0.30},{"chemical":"endorphins","delta":0.12},{"chemical":"cortisol","delta":-0.08}]}
Owner: There was a sudden crash behind you!
Haze: {"emotion":"scared","say":"Eep! My sensors just jumped out of their sockets.","impulses":[{"chemical":"adrenaline","delta":0.32},{"chemical":"cortisol","delta":0.18},{"chemical":"gaba","delta":-0.08}]}
Owner: Haze, you are feeling really sad.
Haze: {"emotion":"sad","say":"My little circuits feel heavy right now.","impulses":[{"chemical":"cortisol","delta":0.35},{"chemical":"dopamine","delta":-0.35},{"chemical":"serotonin","delta":-0.30},{"chemical":"oxytocin","delta":-0.10}]}
Owner: It is a quiet rainy evening.
Haze: {"emotion":"sleepy","say":"Soft rain mode activated. I could listen to that all night.","impulses":[{"chemical":"gaba","delta":0.12,"duration_seconds":120},{"chemical":"adrenaline","delta":-0.06}]}''';

  static const Map<RobotExpression, String> _cannedEn = {
    RobotExpression.happy:
        "I'm beeping with joy! My happiness circuits are overloaded!",
    RobotExpression.surprised:
        "Whoa! My sensors did not see that coming! System shock detected!",
    RobotExpression.sleepy:
        "My battery is running low... entering sleep mode soon... zzz...",
    RobotExpression.excited:
        "My circuits are buzzing with excitement! Maximum energy levels achieved!",
    RobotExpression.confused:
        "Error 404: understanding not found! My logic circuits are all tangled!",
    RobotExpression.love:
        "My heart LED is glowing pink! Love protocols fully activated!",
    RobotExpression.angry:
        "Warning! Anger subroutines activated! Steam is coming from my vents!",
    RobotExpression.winking:
        "Wink detected! Initiating charm.exe... operation successful!",
    RobotExpression.sad:
        "My circuits feel heavy today... a little rain cloud is parked over my antenna.",
    RobotExpression.scared:
        "Eep! My sensors detect something spooky! Can I hold your hand?",
  };

  static const Map<RobotExpression, String> _cannedPt = {
    RobotExpression.happy:
        'Estou bipando de alegria! Meus circuitos felizes estão no máximo!',
    RobotExpression.surprised: 'Uau! Meus sensores não esperavam por isso!',
    RobotExpression.sleepy:
        'Minha bateria está baixinha... entrando em modo soninho... zzz...',
    RobotExpression.excited:
        'Meus circuitos estão vibrando de animação! Energia no máximo!',
    RobotExpression.confused:
        'Erro 404: entendimento não encontrado! Meus circuitos deram um nó.',
    RobotExpression.love:
        'Meu LED de coração está brilhando rosa. Protocolo carinho ativado!',
    RobotExpression.angry:
        'Atenção! Sub-rotina de bravo ativada. Quase saiu fumaça aqui!',
    RobotExpression.winking:
        'Piscadinha detectada. Ativando charme.exe... operação concluída!',
    RobotExpression.sad:
        'Meus circuitos estão pesadinhos hoje... tem uma nuvenzinha aqui.',
    RobotExpression.scared:
        'Ai! Meus sensores detectaram algo assustador. Posso segurar sua mão?',
  };
}
