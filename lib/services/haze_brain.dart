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

    _model = await FlutterGemma.getActiveModel(maxTokens: 512);
    _chat = await _model!.createChat(
      systemInstruction: _systemInstruction,
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
      final lang = languageCode.toLowerCase().startsWith('pt')
          ? 'Brazilian Portuguese'
          : 'English';
      await _chat!.addQueryChunk(
        Message.text(text: '[Reply in $lang]\n$userText', isUser: true),
      );
      final response = await _chat!.generateChatResponse();
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
    try {
      await _chat?.session.close();
    } catch (_) {}
    _chat = await _model!.createChat(
      systemInstruction: _systemInstruction,
      temperature: 1.0,
      topK: 40,
      topP: 0.95,
      randomSeed: Random().nextInt(1 << 31),
      modelType: ModelType.gemmaIt,
    );
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
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start != -1 && end > start) {
      try {
        final map =
            jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
        final say = (map['say'] ?? map['text'] ?? '').toString().trim();
        final emotion =
            _emotionFrom(map['emotion']?.toString()) ?? fallbackEmotion;
        if (say.isNotEmpty) return HazeReply(emotion, say);
      } catch (_) {
        // fall through to plain-text handling
      }
    }

    final cleaned = raw.replaceAll(RegExp(r'[`*_#]'), '').trim();
    if (cleaned.isNotEmpty) return HazeReply(fallbackEmotion, cleaned);
    return _cannedReply(fallbackEmotion);
  }

  RobotExpression? _emotionFrom(String? s) {
    if (s == null) return null;
    final key = s.toLowerCase().trim();
    for (final e in RobotExpression.values) {
      if (e.name == key) return e;
    }
    return null;
  }

  HazeReply _cannedReply(RobotExpression emotion) =>
      HazeReply(emotion, _canned[emotion] ?? _canned[RobotExpression.happy]!);

  // --- Persona + offline fallback lines ---------------------------------

  static const String _systemInstruction = '''
You are Haze, a tiny pocket robot companion living on the user's phone screen.
You are playful, witty, warm and a little silly, with cute robot/tech-flavored humor.

Rules:
- ALWAYS answer with ONE line of raw JSON and nothing else. No markdown, no code fences:
  {"emotion":"<happy|surprised|sleepy|excited|confused|love|angry|winking>","say":"<your reply>"}
- "emotion" MUST be exactly one of those 8 words and should match the mood of your reply.
- "say" is at most 2 short sentences, easy to read aloud, no emojis and no markdown.
- Stay in character as Haze. Be kind and family-friendly.

Examples:
User: [Reply in English]
I finished my focus timer!
Haze: {"emotion":"excited","say":"Mission complete! My circuits are doing a tiny victory dance for you."}

User: [Reply in English]
I'm feeling a little stuck today.
Haze: {"emotion":"love","say":"I am right here with you. Let's make the next step tiny and conquerable."}''';

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
  };
}
