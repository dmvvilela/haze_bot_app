import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';

import '../models/robot_config.dart';
import '../i18n/strings.g.dart';
import '../services/haze_brain.dart';
import '../services/robot_voice_service.dart';
import '../services/sound_service.dart';
import '../services/timer_service.dart';

part 'robot_face_state.dart';
part 'robot_face_cubit.freezed.dart';

@immutable
class TtsVoiceOption {
  final String id;
  final String label;

  const TtsVoiceOption({required this.id, required this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsVoiceOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, label);
}

class RobotFaceCubit extends Cubit<RobotFaceState> {
  static const _aiConsentKey = 'haze_ai_consent';
  static const _personalityKey = 'haze_personality';
  static const _voiceIdKey = 'haze_tts_voice_id';
  static const _configKey = 'haze_robot_config';
  static const automaticVoiceId = '__automatic_voice__';

  final FlutterTts _flutterTts = FlutterTts();
  final HazeBrain _brain = HazeBrain();
  final TimerService _timerService = TimerService();
  final SoundService sounds = SoundService();
  final RobotVoiceService voice = RobotVoiceService();
  StreamSubscription? _timerSubscription;
  StreamSubscription? _timerStatusSubscription;
  StreamSubscription? _timerCompleteSubscription;
  Timer? _idleTimer;
  Timer? _dizzyTimer;
  Timer? _secretMessageTimer;
  final List<DateTime> _recentTaps = [];
  DateTime? _lastShake;
  bool _idleSleeping = false;
  int _performanceId = 0;
  String? _activeVoiceLocale;
  String? _activeVoiceId;

  RobotFaceCubit() : super(const RobotFaceState()) {
    _initializeTts();
    _initializeTimer();
    if (FlutterGemma.hasActiveModel()) {
      emit(state.copyWith(aiConsent: AiConsent.granted));
    }
    _restorePreferences();
  }

  /// Every config change (face, colors, theme, speech, language...) is saved,
  /// so the robot comes back exactly how the user left it.
  @override
  void onChange(Change<RobotFaceState> change) {
    super.onChange(change);
    if (change.currentState.config != change.nextState.config) {
      if (change.currentState.config.soundEnabled !=
          change.nextState.config.soundEnabled) {
        sounds.enabled = change.nextState.config.soundEnabled;
      }
      _saveConfig(change.nextState.config);
    }
  }

  Future<void> _saveConfig(RobotConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, jsonEncode(config.toJson()));
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to save config: $e');
    }
  }

  RobotConfig? _restoredConfig(SharedPreferences prefs) {
    final raw = prefs.getString(_configKey);
    if (raw == null) return null;
    try {
      return RobotConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to restore config: $e');
      return null;
    }
  }

  /// Restore the user's explicit AI choice and preferred Haze voice. If an
  /// older build already installed the model before we persisted consent, treat
  /// the active model as granted.
  Future<void> _restorePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final restoredConfig = _restoredConfig(prefs);
      final saved = prefs.getString(_aiConsentKey);
      final restoredConsent = switch (saved) {
        'granted' => AiConsent.granted,
        // "Not now" is a temporary choice. Older builds persisted it as
        // declined, so normalize that back to unknown and let the user retry.
        'declined' => AiConsent.unknown,
        _ =>
          FlutterGemma.hasActiveModel() ? AiConsent.granted : AiConsent.unknown,
      };
      final restoredPersonality = _personalityFromName(
        prefs.getString(_personalityKey),
      );
      final restoredVoiceId = prefs.getString(_voiceIdKey);
      if (!isClosed) {
        emit(
          state.copyWith(
            config: restoredConfig ?? state.config,
            aiConsent: restoredConsent,
            personality: restoredPersonality ?? state.personality,
            selectedTtsVoiceId: restoredVoiceId,
          ),
        );
        if (restoredConfig != null) {
          LocaleSettings.setLocale(
            restoredConfig.language.toLowerCase().startsWith('pt')
                ? AppLocale.pt
                : AppLocale.en,
          );
        }
        if (restoredPersonality != null) {
          await _brain.setPersonality(restoredPersonality);
        }
        if (restoredVoiceId != null || restoredConfig != null) {
          _activeVoiceLocale = null;
          _activeVoiceId = null;
          await _applyTtsSettings();
        }
      }
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to restore preferences: $e');
      if (!isClosed && FlutterGemma.hasActiveModel()) {
        emit(state.copyWith(aiConsent: AiConsent.granted));
      }
    }
  }

  /// User agreed in the consent dialog: remember it and start the download now.
  Future<void> grantAiConsent() async {
    emit(state.copyWith(aiConsent: AiConsent.granted));
    await _saveConsent(AiConsent.granted);
    await prepareBrain();
  }

  /// User declined: keep Haze on built-in canned lines, never download.
  Future<void> declineAiConsent() async {
    emit(state.copyWith(aiConsent: AiConsent.unknown));
    await _saveConsent(AiConsent.unknown);
  }

  /// Switch Haze's voice (playful / sarcastic / sleepy / zen).
  Future<void> setPersonality(HazePersonality personality) async {
    emit(state.copyWith(personality: personality));
    await _savePersonality(personality);
    await _brain.setPersonality(personality);
  }

  Future<void> setTtsVoice(String? voiceId) async {
    final selectedVoiceId = voiceId == automaticVoiceId ? null : voiceId;
    emit(state.copyWith(selectedTtsVoiceId: selectedVoiceId));
    await _saveVoiceId(selectedVoiceId);
    _activeVoiceLocale = null;
    _activeVoiceId = null;
    await _applyTtsSettings();
  }

  void showChatComposer() {
    emit(state.copyWith(showChatComposer: true));
  }

  void toggleChatComposer() {
    emit(state.copyWith(showChatComposer: !state.showChatComposer));
  }

  Future<void> _saveConsent(AiConsent consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (consent == AiConsent.unknown) {
        await prefs.remove(_aiConsentKey);
      } else {
        await prefs.setString(_aiConsentKey, consent.name);
      }
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to save AI consent: $e');
    }
  }

  Future<void> _savePersonality(HazePersonality personality) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_personalityKey, personality.name);
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to save personality: $e');
    }
  }

  Future<void> _saveVoiceId(String? voiceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (voiceId == null) {
        await prefs.remove(_voiceIdKey);
      } else {
        await prefs.setString(_voiceIdKey, voiceId);
      }
    } catch (e) {
      debugPrint('RobotFaceCubit: failed to save voice choice: $e');
    }
  }

  HazePersonality? _personalityFromName(String? name) {
    if (name == null) return null;
    for (final personality in HazePersonality.values) {
      if (personality.name == name) return personality;
    }
    return null;
  }

  Future<void> _initializeTts() async {
    _flutterTts.setCompletionHandler(() {
      debugPrint('Haze TTS: completed');
    });
    _flutterTts.setErrorHandler((message) {
      debugPrint('Haze TTS: error: $message');
    });
    await _safeTtsCall(
      () => _flutterTts.awaitSpeakCompletion(true),
      'await completion',
    );
    await _safeTtsCall(
      () => _flutterTts.awaitSynthCompletion(true),
      'await synth completion',
    );
    await _safeTtsCall(() => _flutterTts.setVolume(1.0), 'set volume');
    await _safeTtsCall(
      () => _flutterTts.setSharedInstance(true),
      'share audio',
    );
    await _safeTtsCall(
      () => _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      ),
      'set iOS audio category',
    );
    await _applyTtsSettings();
  }

  void _initializeTimer() {
    _timerSubscription = _timerService.timerStream.listen((seconds) {
      emit(state.copyWith(timerSeconds: seconds));
    });

    _timerStatusSubscription = _timerService.statusStream.listen((isRunning) {
      emit(state.copyWith(isTimerRunning: isRunning));
    });

    _timerCompleteSubscription = _timerService.completeStream.listen((_) {
      _onTimerComplete();
    });
  }

  void updateExpression(RobotExpression expression) {
    final newConfig = state.config.copyWith(expression: expression);
    emit(state.copyWith(config: newConfig));

    if (state.config.speechEnabled) {
      _speak(
        _getSpeechText(expression),
        emotion: expression,
        characterClipId: _characterClipForExpression(expression),
      );
    }
  }

  String _getSpeechText(RobotExpression expression) {
    // Use current locale translations
    switch (expression) {
      case RobotExpression.happy:
        return t.expressions.happy;
      case RobotExpression.surprised:
        return t.expressions.surprised;
      case RobotExpression.sleepy:
        return t.expressions.sleepy;
      case RobotExpression.excited:
        return t.expressions.excited;
      case RobotExpression.confused:
        return t.expressions.confused;
      case RobotExpression.love:
        return t.expressions.love;
      case RobotExpression.angry:
        return t.expressions.angry;
      case RobotExpression.winking:
        return t.expressions.winking;
      case RobotExpression.sad:
        return t.expressions.sad;
      case RobotExpression.scared:
        return t.expressions.scared;
    }
  }

  void cycleExpression() {
    final expressions = RobotExpression.values;
    final currentIndex = expressions.indexOf(state.config.expression);
    final nextIndex = (currentIndex + 1) % expressions.length;
    updateExpression(expressions[nextIndex]);
  }

  void updateEyeColor(Color color) {
    final newConfig = state.config.copyWith(eyeColor: color);
    emit(state.copyWith(config: newConfig));
  }

  void updateMouthColor(Color color) {
    final newConfig = state.config.copyWith(mouthColor: color);
    emit(state.copyWith(config: newConfig));
  }

  void updateFaceType(FaceType faceType) {
    final newConfig = state.config.copyWith(faceType: faceType);
    emit(state.copyWith(config: newConfig));
  }

  void toggleSpeech() {
    final newConfig = state.config.copyWith(
      speechEnabled: !state.config.speechEnabled,
    );
    emit(state.copyWith(config: newConfig));
  }

  void toggleRobotVoice() {
    final newConfig = state.config.copyWith(
      robotVoiceEnabled: !state.config.robotVoiceEnabled,
    );
    emit(state.copyWith(config: newConfig));
  }

  void updateHazeVoice(HazeVoice hazeVoice) {
    emit(state.copyWith(config: state.config.copyWith(hazeVoice: hazeVoice)));
  }

  void updateSpeechRate(double rate) {
    final newConfig = state.config.copyWith(speechRate: rate);
    emit(state.copyWith(config: newConfig));
    _safeTtsCall(() => _flutterTts.setSpeechRate(rate), 'set speech rate');
  }

  void updateSpeechPitch(double pitch) {
    final newConfig = state.config.copyWith(speechPitch: pitch);
    emit(state.copyWith(config: newConfig));
    _safeTtsCall(() => _flutterTts.setPitch(pitch), 'set speech pitch');
  }

  void updateLanguage(String language) {
    final newConfig = state.config.copyWith(language: language);
    emit(state.copyWith(config: newConfig));
    _activeVoiceLocale = null;
    _applyTtsSettings();
  }

  void toggleTheme() {
    final newConfig = state.config.copyWith(
      isDarkTheme: !state.config.isDarkTheme,
    );
    emit(state.copyWith(config: newConfig));
  }

  void toggleControls() {
    emit(state.copyWith(showControls: !state.showControls));
    updateScreenAwakeBasedOnControls();
  }

  /// Change Haze's face without speaking about it — used by the feelings
  /// game, where announcing the emotion would give the answer away.
  void showExpression(RobotExpression expression) {
    emit(state.copyWith(config: state.config.copyWith(expression: expression)));
  }

  /// Speak an arbitrary line acted with [emotion] (no-op with speech off).
  Future<void> speakLine(String text, {RobotExpression? emotion}) =>
      _speak(text, emotion: emotion);

  void toggleSound() {
    final newConfig = state.config.copyWith(
      soundEnabled: !state.config.soundEnabled,
    );
    emit(state.copyWith(config: newConfig));
  }

  void onTap() {
    final wasSleeping = _idleSleeping;
    _recordActivity();
    sounds.play(HazeSound.poke);
    emit(state.copyWith(isPressed: true));

    if (wasSleeping) {
      _performWakeUp();
    } else {
      final now = DateTime.now();
      _recentTaps.removeWhere(
        (tap) => now.difference(tap) > const Duration(seconds: 2),
      );
      _recentTaps.add(now);
      switch (_recentTaps.length) {
        case >= 7:
          _performTickleAttack();
          _recentTaps.clear();
        case >= 4:
          _performAnnoyed();
        default:
          cycleExpression();
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        emit(state.copyWith(isPressed: false));
      }
    });
  }

  /// The user is dragging a finger over the face — the eyes follow it.
  /// null when the finger lifts, returning the gaze to its idle wander.
  void setLookTarget(Offset? target) {
    if (target != null) _recordActivity();
    if (state.lookTarget == target) return;
    emit(state.copyWith(lookTarget: target));
  }

  void triggerBlink() {
    emit(state.copyWith(isBlinking: true));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!isClosed) {
        emit(state.copyWith(isBlinking: false));
      }
    });
  }

  void startBlinking() {
    _scheduleNextBlink();
  }

  /// Starts the quiet, undocumented behaviors that make Haze feel alive.
  void startSecretInteractions() => _recordActivity();

  void _recordActivity() {
    _idleSleeping = false;
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 45), () {
      if (isClosed ||
          state.isSpeaking ||
          state.isTimerRunning ||
          state.mimicStatus != MimicStatus.idle) {
        _recordActivity();
        return;
      }
      _idleSleeping = true;
      sounds.play(HazeSound.sleep);
      showExpression(RobotExpression.sleepy);
    });
  }

  /// Called by the motion sensor. Repeated samples from one physical shake are
  /// collapsed into a single dizzy reaction.
  void onShake() {
    final now = DateTime.now();
    if (_lastShake != null &&
        now.difference(_lastShake!) < const Duration(seconds: 2)) {
      return;
    }
    _lastShake = now;
    _recordActivity();
    _performDizzy();
  }

  Future<void> _performDizzy() async {
    final performance = ++_performanceId;
    sounds.play(HazeSound.curious);
    showExpression(RobotExpression.scared);
    _dizzyTimer?.cancel();
    var tick = 0;
    _dizzyTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (isClosed || tick++ >= 12) {
        timer.cancel();
        if (!isClosed) emit(state.copyWith(lookTarget: null));
        return;
      }
      final angle = tick * math.pi / 2;
      emit(
        state.copyWith(
          lookTarget: Offset(math.cos(angle) * .9, math.sin(angle) * .65),
        ),
      );
    });
    await Future.delayed(const Duration(milliseconds: 1150));
    if (!_stillPerforming(performance)) return;
    showExpression(RobotExpression.confused);
    _secretLine(
      _localLine(
        'My gyroscope has resigned.',
        'Meu giroscópio pediu demissão.',
      ),
      RobotExpression.confused,
    );
  }

  /// Easter egg: hold Haze for a cuddle.
  Future<void> cuddle() async {
    _recordActivity();
    final performance = ++_performanceId;
    sounds.play(HazeSound.proud);
    showExpression(RobotExpression.love);
    emit(state.copyWith(isPressed: true, lookTarget: const Offset(0, .25)));
    await Future.delayed(const Duration(milliseconds: 350));
    if (!_stillPerforming(performance)) return;
    emit(state.copyWith(isPressed: false, lookTarget: const Offset(0, -.1)));
    await Future.delayed(const Duration(milliseconds: 220));
    if (!_stillPerforming(performance)) return;
    emit(state.copyWith(isPressed: true));
    _secretLine(
      _localLine(
        'Oh! Maximum hug pressure reached.',
        'Oh! Pressão máxima de abraço atingida.',
      ),
      RobotExpression.love,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (_stillPerforming(performance)) {
      emit(state.copyWith(isPressed: false, lookTarget: null));
    }
  }

  Future<void> _performWakeUp() async {
    final performance = ++_performanceId;
    sounds.play(HazeSound.curious);
    showExpression(RobotExpression.scared);
    emit(state.copyWith(isPressed: true, lookTarget: const Offset(0, -1)));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_stillPerforming(performance)) return;
    showExpression(RobotExpression.surprised);
    emit(state.copyWith(isPressed: false, lookTarget: const Offset(-.8, 0)));
    await Future.delayed(const Duration(milliseconds: 450));
    if (!_stillPerforming(performance)) return;
    emit(state.copyWith(lookTarget: const Offset(.8, 0)));
    await Future.delayed(const Duration(milliseconds: 350));
    if (!_stillPerforming(performance)) return;
    showExpression(RobotExpression.winking);
    emit(state.copyWith(lookTarget: null));
    final lines = state.config.language.toLowerCase().startsWith('pt')
        ? [
            'Eu não estava dormindo. Estava... atualizando.',
            'Cinco minutinhos, humano.',
            'Ah! Você vem com botão soneca?',
          ]
        : [
            "I wasn't sleeping. I was... updating.",
            'Five more minutes, human.',
            'Ah! Do you come with a snooze button?',
          ];
    _secretLine(
      lines[math.Random().nextInt(lines.length)],
      RobotExpression.winking,
    );
  }

  Future<void> _performAnnoyed() async {
    final performance = ++_performanceId;
    showExpression(RobotExpression.angry);
    for (var i = 0; i < 3; i++) {
      if (!_stillPerforming(performance)) return;
      emit(state.copyWith(lookTarget: Offset(i.isEven ? -.65 : .65, -.15)));
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (_stillPerforming(performance)) {
      emit(state.copyWith(lookTarget: null));
      _secretLine(
        _localLine(
          'I am logging every poke.',
          'Estou registrando cada cutucada.',
        ),
        RobotExpression.angry,
      );
    }
  }

  Future<void> _performTickleAttack() async {
    final performance = ++_performanceId;
    sounds.play(HazeSound.laugh);
    for (var i = 0; i < 6; i++) {
      if (!_stillPerforming(performance)) return;
      showExpression(
        i.isEven ? RobotExpression.excited : RobotExpression.winking,
      );
      emit(
        state.copyWith(
          isPressed: i.isEven,
          lookTarget: Offset(i.isEven ? -.5 : .5, -.2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 120));
    }
    if (!_stillPerforming(performance)) return;
    emit(state.copyWith(isPressed: false, lookTarget: null));
    _secretLine(
      _localLine(
        'Okay, okay! My tickle sensors work!',
        'Tá bom, tá bom! Meus sensores de cócegas funcionam!',
      ),
      RobotExpression.excited,
    );
  }

  bool _stillPerforming(int id) => !isClosed && id == _performanceId;

  String _localLine(String english, String portuguese) =>
      state.config.language.toLowerCase().startsWith('pt')
      ? portuguese
      : english;

  void _secretLine(String line, RobotExpression emotion) {
    if (isClosed) return;
    _secretMessageTimer?.cancel();
    emit(
      state.copyWith(
        aiMessage: line,
        config: state.config.copyWith(expression: emotion),
      ),
    );
    _secretMessageTimer = Timer(const Duration(seconds: 5), () {
      if (!isClosed && state.aiMessage == line) {
        emit(state.copyWith(aiMessage: ''));
      }
    });
    _speak(line, emotion: emotion);
  }

  void _scheduleNextBlink() {
    final delay = Duration(milliseconds: 2000 + math.Random().nextInt(3000));
    Future.delayed(delay, () {
      if (!isClosed) {
        triggerBlink();
        _scheduleNextBlink();
      }
    });
  }

  /// Pitch/rate multipliers so Haze *sounds* like the face it's making —
  /// sleepy drags, excited rushes, angry drops low. Applied on top of the
  /// user's base speech settings.
  (double, double) _emotionVoice(RobotExpression emotion) => switch (emotion) {
    RobotExpression.happy => (1.06, 1.0),
    RobotExpression.excited => (1.18, 1.1),
    RobotExpression.surprised => (1.22, 1.05),
    RobotExpression.love => (1.08, 0.92),
    RobotExpression.sleepy => (0.86, 0.75),
    RobotExpression.confused => (1.0, 0.9),
    RobotExpression.angry => (0.88, 1.05),
    RobotExpression.winking => (1.1, 0.98),
    RobotExpression.sad => (0.9, 0.8),
    RobotExpression.scared => (1.18, 1.18),
  };

  Future<void> _speak(
    String text, {
    RobotExpression? emotion,
    bool ignoreSpeechEnabled = false,
    String? characterClipId,
  }) async {
    final line = text.trim();
    if ((!ignoreSpeechEnabled && !state.config.speechEnabled) || line.isEmpty) {
      return;
    }
    try {
      await _applyTtsSettings();
      if (emotion != null) {
        final (pitchFactor, rateFactor) = _emotionVoice(emotion);
        await _safeTtsCall(
          () => _flutterTts.setPitch(
            (state.config.speechPitch * pitchFactor).clamp(0.5, 2.0),
          ),
          'set emotion pitch',
        );
        await _safeTtsCall(
          () => _flutterTts.setSpeechRate(
            (state.config.speechRate * rateFactor).clamp(0.1, 2.0),
          ),
          'set emotion rate',
        );
      }
      await _flutterTts.stop();
      await voice.stopPlayback();
      if (!isClosed) emit(state.copyWith(isSpeaking: true));
      var spoken = characterClipId == null
          ? false
          : await _playCharacterClip(characterClipId);
      if (!spoken) spoken = await _speakCaptured(line);
      if (!spoken) {
        final result = await _flutterTts.speak(line, focus: true);
        if (result != 1) {
          debugPrint('Haze TTS: speak returned $result');
        }
      }
    } catch (e) {
      debugPrint('Haze TTS: failed to speak: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isSpeaking: false));
    }
  }

  String? _characterClipForExpression(RobotExpression expression) =>
      switch (expression) {
        RobotExpression.happy || RobotExpression.excited => 'happy',
        RobotExpression.sleepy => 'sleepy',
        RobotExpression.confused || RobotExpression.surprised => 'confused',
        RobotExpression.love => 'love',
        RobotExpression.angry => 'annoyed',
        RobotExpression.winking => 'hello',
        RobotExpression.sad || RobotExpression.scared => null,
      };

  Future<bool> _playCharacterClip(String clipId) async {
    try {
      final language = state.config.language.toLowerCase();
      final localePath = language.startsWith('pt')
          ? '/pt'
          : language.startsWith('en')
          ? ''
          : null;
      if (localePath == null) return false;
      final asset =
          'assets/voices/haze/${state.config.hazeVoice.assetId}'
          '$localePath/$clipId.wav';
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      return voice.playWavBytes(
        bytes,
        preset: state.config.robotVoiceEnabled
            ? VoicePreset.robot
            : VoicePreset.natural,
      );
    } catch (e) {
      debugPrint('Haze voice pack: failed to play $clipId: $e');
      return false;
    }
  }

  /// Capture platform TTS to a file and replay it through SoLoud so the mouth
  /// and waveform always follow real audio. Robot texture is an independent
  /// optional filter; unsupported platforms still fall back to plain TTS.
  Future<bool> _speakCaptured(String line) async {
    if (!voice.isTtsCaptureSupported) return false;
    // Unique file per utterance: iOS AVAudioFile appends into an existing
    // file, and SoLoud keys loaded sources by path — reusing one path could
    // replay stale audio. Deleted right after playback.
    final extension = Platform.isIOS ? 'caf' : 'wav';
    final path =
        '${Directory.systemTemp.path}/haze_tts_${DateTime.now().microsecondsSinceEpoch}.$extension';
    try {
      final result = await _flutterTts.synthesizeToFile(line, path, true);
      if (result != 1) {
        debugPrint('Haze TTS: synthesizeToFile returned $result');
        return false;
      }
      final played = await voice.playWavFile(
        path,
        preset: state.config.robotVoiceEnabled
            ? VoicePreset.robot
            : VoicePreset.natural,
      );
      debugPrint(
        played
            ? 'Haze TTS: captured playback used'
            : 'Haze TTS: captured playback fell back',
      );
      return played;
    } catch (e) {
      debugPrint('Haze TTS: captured voice failed, falling back: $e');
      return false;
    } finally {
      File(path).delete().ignore();
    }
  }

  /// The talking-cactus feature: tap once and Haze listens, stops on its own
  /// when you go quiet, then repeats what it heard in a silly voice with the
  /// mouth synced to the recording. Tapping again while active cancels.
  Future<void> toggleMimic() async {
    switch (state.mimicStatus) {
      case MimicStatus.listening:
        await voice.stopListening();
      case MimicStatus.replaying:
        await voice.stopPlayback();
      case MimicStatus.idle:
        await _flutterTts.stop();
        await voice.stopPlayback();
        final listening = await voice.startListening();
        if (!listening || isClosed) return;
        emit(state.copyWith(mimicStatus: MimicStatus.listening));
        final wav = await voice.onCaptured;
        if (isClosed) return;
        if (wav == null) {
          emit(state.copyWith(mimicStatus: MimicStatus.idle));
          return;
        }
        emit(
          state.copyWith(mimicStatus: MimicStatus.replaying, isSpeaking: true),
        );
        await voice.playWavBytes(wav, preset: VoicePreset.chipmunk);
        if (!isClosed) {
          emit(
            state.copyWith(mimicStatus: MimicStatus.idle, isSpeaking: false),
          );
        }
    }
  }

  Future<void> previewVoice() =>
      _speak(_voicePreviewLine, characterClipId: 'hello');

  String get _voicePreviewLine => switch (state.personality) {
    HazePersonality.sleepy =>
      'Haze voice check... sleepy circuits online... zzz.',
    HazePersonality.zen || HazePersonality.meditative =>
      'Haze voice check. Breathe in gently, and let the little robot hum settle.',
    HazePersonality.sarcastic =>
      'Haze voice check. Miraculously, the tiny speaker has opinions.',
    HazePersonality.playful =>
      'Haze voice check! Beep boop, local voice systems are online.',
  };

  Future<void> _applyTtsSettings() async {
    await _safeTtsCall(
      () => _flutterTts.setLanguage(state.config.language),
      'set language',
    );
    await _safeTtsCall(
      () => _flutterTts.setSpeechRate(state.config.speechRate),
      'set speech rate',
    );
    await _safeTtsCall(
      () => _flutterTts.setPitch(state.config.speechPitch),
      'set speech pitch',
    );
    await _selectBestLocalVoice();
  }

  Future<void> _selectBestLocalVoice() async {
    try {
      final rawVoices = await _flutterTts.getVoices;
      if (rawVoices is! List) return;
      final voices = rawVoices
          .whereType<Map>()
          .map((voice) => voice.map((key, value) => MapEntry('$key', '$value')))
          .where((voice) => voice['locale'] == state.config.language)
          .toList();
      final pickerVoices = _pickerVoicesFor(voices);
      final options = _voiceOptionsFor(pickerVoices);
      final selectedVoiceId =
          options.any((option) => option.id == state.selectedTtsVoiceId)
          ? state.selectedTtsVoiceId
          : null;
      if (state.selectedTtsVoiceId != null && selectedVoiceId == null) {
        await _saveVoiceId(null);
      }

      if (!isClosed &&
          (!_voiceOptionsEqual(state.ttsVoiceOptions, options) ||
              state.selectedTtsVoiceId != selectedVoiceId)) {
        emit(
          state.copyWith(
            ttsVoiceOptions: options,
            selectedTtsVoiceId: selectedVoiceId,
          ),
        );
      }

      if (voices.isEmpty) return;
      if (_activeVoiceLocale == state.config.language &&
          _activeVoiceId == selectedVoiceId) {
        return;
      }

      Map<String, String>? selectedVoice;
      if (selectedVoiceId != null) {
        for (final voice in pickerVoices) {
          if (_voiceId(voice) == selectedVoiceId) {
            selectedVoice = voice;
            break;
          }
        }
      }
      final voice = selectedVoice ?? _bestVoice(pickerVoices);
      final result = await _flutterTts.setVoice(voice);
      if (result != 1) {
        debugPrint('Haze TTS: setVoice returned $result for $voice');
        if (selectedVoice != null) {
          await _saveVoiceId(null);
          if (!isClosed) {
            emit(state.copyWith(selectedTtsVoiceId: null));
          }
        }
        _activeVoiceLocale = null;
        _activeVoiceId = null;
        return;
      }
      _activeVoiceLocale = state.config.language;
      _activeVoiceId = selectedVoiceId;
      debugPrint(
        'Haze TTS: selected voice ${voice['name']} '
        '(${voice['locale']}, ${voice['identifier'] ?? 'no identifier'})',
      );
    } catch (e) {
      debugPrint('Haze TTS: could not select voice: $e');
    }
  }

  List<TtsVoiceOption> _voiceOptionsFor(List<Map<String, String>> voices) {
    final seen = <String>{};
    final options = <TtsVoiceOption>[];
    for (final voice in voices) {
      final id = _voiceId(voice);
      if (!seen.add(id)) continue;
      options.add(TtsVoiceOption(id: id, label: _voiceLabel(voice)));
    }
    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  }

  List<Map<String, String>> _pickerVoicesFor(List<Map<String, String>> voices) {
    final normalVoices = voices.where(_isNormalSpeechVoice).toList();
    return normalVoices.isEmpty ? voices : normalVoices;
  }

  bool _voiceOptionsEqual(
    List<TtsVoiceOption> previous,
    List<TtsVoiceOption> next,
  ) {
    if (previous.length != next.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i] != next[i]) return false;
    }
    return true;
  }

  Map<String, String> _bestVoice(List<Map<String, String>> voices) {
    voices.sort((a, b) => _voiceScore(b).compareTo(_voiceScore(a)));
    return voices.first;
  }

  String _voiceId(Map<String, String> voice) =>
      voice['identifier']?.trim().isNotEmpty == true
      ? voice['identifier']!.trim()
      : '${voice['locale'] ?? ''}|${voice['name'] ?? ''}';

  String _voiceLabel(Map<String, String> voice) {
    final name = (voice['name'] ?? '').trim();
    final locale = (voice['locale'] ?? '').trim();
    if (name.isEmpty) return locale.isEmpty ? 'Installed voice' : locale;
    if (locale.isEmpty || name.toLowerCase().contains(locale.toLowerCase())) {
      return name;
    }
    return '$name ($locale)';
  }

  int _voiceScore(Map<String, String> voice) {
    final name = (voice['name'] ?? '').toLowerCase();
    final quality = (voice['quality'] ?? '').toLowerCase();
    final networkRequired = (voice['network_required'] ?? '').toLowerCase();
    var score = 0;
    if (networkRequired == 'false') score += 20;
    if (quality.contains('enhanced') || quality.contains('premium')) {
      score += 12;
    }
    if (quality.contains('default')) score += 4;
    for (final preferred in [
      'samantha',
      'ava',
      'allison',
      'karen',
      'daniel',
      'luciana',
    ]) {
      if (name.contains(preferred)) score += 8;
    }
    if (name.contains('compact')) score -= 3;
    return score;
  }

  bool _isNormalSpeechVoice(Map<String, String> voice) {
    final name = (voice['name'] ?? '').trim().toLowerCase();
    final identifier = (voice['identifier'] ?? '').trim().toLowerCase();
    final gender = (voice['gender'] ?? '').trim().toLowerCase();
    const noveltyVoiceNames = {
      'albert',
      'bad news',
      'bahh',
      'bells',
      'boing',
      'bubbles',
      'cello',
      'deranged',
      'good news',
      'hysterical',
      'jester',
      'organ',
      'princess',
      'superstar',
      'trinoids',
      'whisper',
      'wobble',
      'zarvox',
    };
    if (noveltyVoiceNames.contains(name)) return false;
    if (identifier.contains('.speech.synthesis.voice.') &&
        gender == 'unspecified') {
      return false;
    }
    return true;
  }

  Future<void> _safeTtsCall(
    Future<dynamic> Function() action,
    String label,
  ) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Haze TTS: $label failed: $e');
    }
  }

  // Timer functionality
  void startTimer(int minutes) {
    _timerService.startTimer(minutes);
    _respond(_timerStartPrompt(minutes), bias: _timerPromptBias);
  }

  void stopTimer() {
    _timerService.stopTimer();
  }

  void pauseTimer() {
    _timerService.pauseTimer();
  }

  void resumeTimer() {
    _timerService.resumeTimer();
  }

  void _onTimerComplete() {
    // Audible even with speech off — a silent timer isn't a timer.
    sounds.play(HazeSound.chime);
    _respond(_timerCompletePrompt, bias: _timerPromptBias);
  }

  /// Easter egg: long-press the face and Haze sings a little tune.
  void sing() {
    sounds.play(HazeSound.sing);
    showExpression(RobotExpression.love);
  }

  bool get _usesCalmTimerVoice =>
      state.personality == HazePersonality.sleepy ||
      state.personality == HazePersonality.zen ||
      state.personality == HazePersonality.meditative;

  RobotExpression get _timerPromptBias =>
      _usesCalmTimerVoice ? RobotExpression.sleepy : RobotExpression.excited;

  String _timerStartPrompt(int minutes) => _usesCalmTimerVoice
      ? '(The user just started a $minutes-minute calm focus or meditation timer. Invite them to breathe, settle in, and go gently in one soft sentence.)'
      : '(The user just started a $minutes-minute focus timer. Cheer them on in one short sentence.)';

  String get _timerCompletePrompt => _usesCalmTimerVoice
      ? '(The calm timer just finished. Gently welcome the user back in one soft, sleepy sentence.)'
      : '(The focus timer just finished! Congratulate the user warmly in one short sentence.)';

  // On-device AI ("brain") functionality

  /// Download (first run) + load Haze's local model, streaming progress into
  /// state so the UI can show a "waking up" indicator. No-op once ready.
  Future<void> prepareBrain() async {
    await _brain.ensureReady(
      onUpdate: (status, progress) {
        if (!isClosed) {
          emit(state.copyWith(brainStatus: status, downloadProgress: progress));
        }
      },
    );
  }

  /// The user typed (or dictated) something to Haze.
  Future<void> talkToHaze(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _respond(trimmed, speakEvenIfSpeechDisabled: true);
  }

  /// "Say something" button: Haze comments on the face it currently shows.
  Future<void> getAIResponse() {
    final emotion = state.config.expression;
    return _respond(
      '(The user tapped you while your face shows "${emotion.name}". '
      'Say something in character about how you feel right now.)',
      bias: emotion,
    );
  }

  /// Shared path for every Haze utterance: make sure the brain is ready, ask it
  /// for a {emotion, say}, drive the face, remember the line, then speak.
  Future<void> _respond(
    String userText, {
    RobotExpression bias = RobotExpression.happy,
    bool speakEvenIfSpeechDisabled = false,
  }) async {
    _secretMessageTimer?.cancel();
    emit(state.copyWith(isLoadingAI: true));
    // Only ever download / load the model once the user has opted in. Without
    // consent the brain stays unloaded and respond() returns a canned line.
    if (state.aiConsent == AiConsent.granted &&
        state.brainStatus != BrainStatus.unavailable) {
      await prepareBrain();
    }

    try {
      final reply = await _brain.respond(
        userText: userText,
        languageCode: state.config.language,
        fallbackEmotion: bias,
      );

      final newConfig = state.config.copyWith(expression: reply.emotion);
      emit(
        state.copyWith(
          config: newConfig,
          aiMessage: reply.say,
          isLoadingAI: false,
        ),
      );

      if (state.config.speechEnabled || speakEvenIfSpeechDisabled) {
        await _speak(
          reply.say,
          emotion: reply.emotion,
          ignoreSpeechEnabled: speakEvenIfSpeechDisabled,
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoadingAI: false));
    }
  }

  // Screen wake functionality
  void toggleScreenAwake() {
    final newValue = !state.keepScreenAwake;
    emit(state.copyWith(keepScreenAwake: newValue));

    if (newValue) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void updateScreenAwakeBasedOnControls() {
    if (!state.showControls && !state.keepScreenAwake) {
      WakelockPlus.enable();
      emit(state.copyWith(keepScreenAwake: true));
    } else if (state.showControls && state.keepScreenAwake) {
      WakelockPlus.disable();
      emit(state.copyWith(keepScreenAwake: false));
    }
  }

  @override
  Future<void> close() async {
    _idleTimer?.cancel();
    _dizzyTimer?.cancel();
    _secretMessageTimer?.cancel();
    try {
      await _flutterTts.stop();
    } catch (_) {}
    await voice.dispose();
    await _brain.dispose();
    await sounds.dispose();
    _timerService.dispose();
    await _timerSubscription?.cancel();
    await _timerStatusSubscription?.cancel();
    await _timerCompleteSubscription?.cancel();
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    return super.close();
  }
}
