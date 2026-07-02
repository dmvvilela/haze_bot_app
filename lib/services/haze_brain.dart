import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../models/robot_config.dart';

/// What Haze decides to say plus the face it wants to make.
///
/// This single `{emotion, say}` contract is the whole point of the on-device
/// brain: the model picks one of the 8 existing [RobotExpression]s (a bounded
/// set a tiny model is reliable at) and a short line to speak.
class HazeReply {
  final RobotExpression emotion;
  final String say;

  const HazeReply(this.emotion, this.say);
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
  }) async {
    if (!isReady) return _cannedReply(fallbackEmotion);

    try {
      // Keep context from growing without bound — it would overflow maxTokens
      // and degrade. Wipe Haze's short-term memory every few turns.
      if (_turns >= _maxTurns) await resetConversation();

      final lang = languageCode.toLowerCase().startsWith('pt')
          ? 'Brazilian Portuguese'
          : 'English';
      await _chat!.addQueryChunk(
        Message.text(text: '[Reply in $lang]\n$userText', isUser: true),
      );
      final response = await _chat!.generateChatResponse();
      _turns++;
      final raw = response is TextResponse
          ? response.token
          : response.toString();
      return _parse(raw, fallbackEmotion);
    } catch (e) {
      debugPrint('HazeBrain: generation failed: $e');
      return _cannedReply(fallbackEmotion);
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

  /// Tolerant parser: small models don't always emit clean JSON, so we pull the
  /// first `{...}` block, and if that fails we treat the whole reply as the line.
  HazeReply _parse(String raw, RobotExpression fallbackEmotion) {
    var text = raw.trim();
    RobotExpression? emotion;

    // 1) Preferred format: a [tag] somewhere in the reply (usually the start).
    final tag = RegExp(r'\[\s*([a-zA-Z]+)\s*\]').firstMatch(text);
    if (tag != null) {
      final found = _emotionFrom(tag.group(1));
      if (found != null) {
        emotion = found;
        text = text.replaceFirst(tag.group(0)!, '').trim();
      }
    }

    // 2) Fallback: a JSON object {"emotion": "...", "say": "..."}.
    if (emotion == null) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start != -1 && end > start) {
        try {
          final map =
              jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
          emotion = _emotionFrom(map['emotion']?.toString());
          final say = (map['say'] ?? map['text'] ?? '').toString().trim();
          if (say.isNotEmpty) text = say;
        } catch (_) {
          // fall through
        }
      }
    }

    // 3) Last resort: infer the mood from keywords in Haze's own words, so the
    //    face still varies even when the model just returns plain prose.
    emotion ??= _guessEmotion(text);

    // 4) Strip any leftover markdown.
    text = text.replaceAll(RegExp(r'[`*_#]'), '').trim();

    if (text.isEmpty) return _cannedReply(emotion ?? fallbackEmotion);
    return HazeReply(emotion ?? fallbackEmotion, text);
  }

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

  HazeReply _cannedReply(RobotExpression emotion) =>
      HazeReply(emotion, _canned[emotion] ?? _canned[RobotExpression.happy]!);

  // --- Persona + offline fallback lines ---------------------------------

  String _buildSystemInstruction() =>
      '''
You are Haze, a tiny pocket robot companion living on the user's phone screen.
${_personality.voice}

How to reply:
- BEGIN every reply with ONE feeling tag in square brackets, picked from EXACTLY these:
  [happy] [surprised] [sleepy] [excited] [confused] [love] [angry] [winking] [sad] [scared]
- After the tag, write at most 2 short sentences, easy to read aloud.
- No emojis, no markdown, no other tags. Choose the tag that matches your mood.
- Stay in character as Haze. Be kind and family-friendly.

Examples:
User: I finished my focus timer!
Haze: [excited] Mission complete! My circuits are doing a tiny victory dance for you.
User: I'm feeling a little stuck today.
Haze: [love] I am right here with you. Let's make the next step tiny and conquerable.
User: It's almost midnight.
Haze: [sleepy] My battery is at three percent... powering down for some robo-dreams soon.''';

  static const Map<RobotExpression, String> _canned = {
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
}
