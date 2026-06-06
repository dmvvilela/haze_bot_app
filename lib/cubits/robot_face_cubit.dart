import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'dart:math' as math;
import 'dart:async';

import '../models/robot_config.dart';
import '../i18n/strings.g.dart';
import '../services/haze_brain.dart';
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
  static const automaticVoiceId = '__automatic_voice__';

  final FlutterTts _flutterTts = FlutterTts();
  final HazeBrain _brain = HazeBrain();
  final TimerService _timerService = TimerService();
  StreamSubscription? _timerSubscription;
  StreamSubscription? _timerStatusSubscription;
  StreamSubscription? _timerCompleteSubscription;
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

  /// Restore the user's explicit AI choice and preferred Haze voice. If an
  /// older build already installed the model before we persisted consent, treat
  /// the active model as granted.
  Future<void> _restorePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
            aiConsent: restoredConsent,
            personality: restoredPersonality ?? state.personality,
            selectedTtsVoiceId: restoredVoiceId,
          ),
        );
        if (restoredPersonality != null) {
          await _brain.setPersonality(restoredPersonality);
        }
        if (restoredVoiceId != null) {
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
      _speak(_getSpeechText(expression));
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

  void onTap() {
    emit(state.copyWith(isPressed: true));
    cycleExpression();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        emit(state.copyWith(isPressed: false));
      }
    });
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

  void _scheduleNextBlink() {
    final delay = Duration(milliseconds: 2000 + math.Random().nextInt(3000));
    Future.delayed(delay, () {
      if (!isClosed) {
        triggerBlink();
        _scheduleNextBlink();
      }
    });
  }

  Future<void> _speak(String text) async {
    final line = text.trim();
    if (!state.config.speechEnabled || line.isEmpty) return;
    try {
      await _applyTtsSettings();
      await _flutterTts.stop();
      if (!isClosed) emit(state.copyWith(isSpeaking: true));
      final result = await _flutterTts.speak(line, focus: true);
      if (result != 1) {
        debugPrint('Haze TTS: speak returned $result');
      }
    } catch (e) {
      debugPrint('Haze TTS: failed to speak: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isSpeaking: false));
    }
  }

  Future<void> previewVoice() => _speak(_voicePreviewLine);

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
      final options = _voiceOptionsFor(voices);
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
        for (final voice in voices) {
          if (_voiceId(voice) == selectedVoiceId) {
            selectedVoice = voice;
            break;
          }
        }
      }
      final voice = selectedVoice ?? _bestVoice(voices);
      await _flutterTts.setVoice(voice);
      _activeVoiceLocale = state.config.language;
      _activeVoiceId = selectedVoiceId;
      debugPrint('Haze TTS: selected voice $voice');
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
      '${voice['locale'] ?? ''}|${voice['name'] ?? ''}';

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
    _respond(_timerCompletePrompt, bias: _timerPromptBias);
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
    return _respond(trimmed);
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
  }) async {
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

      if (state.config.speechEnabled) {
        await _speak(reply.say);
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
    try {
      await _flutterTts.stop();
    } catch (_) {}
    await _brain.dispose();
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
