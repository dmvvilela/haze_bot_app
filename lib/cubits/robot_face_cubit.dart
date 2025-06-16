import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:math' as math;
import 'dart:async';

import '../models/robot_config.dart';
import '../i18n/strings.g.dart';
import '../services/gemini_service.dart';
import '../services/timer_service.dart';

part 'robot_face_state.dart';
part 'robot_face_cubit.freezed.dart';

class RobotFaceCubit extends Cubit<RobotFaceState> {
  final FlutterTts _flutterTts = FlutterTts();
  final GeminiService _geminiService = GeminiService();
  final TimerService _timerService = TimerService();
  StreamSubscription? _timerSubscription;
  StreamSubscription? _timerStatusSubscription;
  StreamSubscription? _timerCompleteSubscription;

  RobotFaceCubit() : super(const RobotFaceState()) {
    _initializeTts();
    _initializeTimer();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(state.config.language);
    await _flutterTts.setSpeechRate(state.config.speechRate);
    await _flutterTts.setPitch(state.config.speechPitch);
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
    final newConfig = state.config.copyWith(speechEnabled: !state.config.speechEnabled);
    emit(state.copyWith(config: newConfig));
  }

  void updateSpeechRate(double rate) {
    final newConfig = state.config.copyWith(speechRate: rate);
    emit(state.copyWith(config: newConfig));
    _flutterTts.setSpeechRate(rate);
  }

  void updateSpeechPitch(double pitch) {
    final newConfig = state.config.copyWith(speechPitch: pitch);
    emit(state.copyWith(config: newConfig));
    _flutterTts.setPitch(pitch);
  }

  void updateLanguage(String language) {
    final newConfig = state.config.copyWith(language: language);
    emit(state.copyWith(config: newConfig));
    _flutterTts.setLanguage(language);
  }

  void toggleTheme() {
    final newConfig = state.config.copyWith(isDarkTheme: !state.config.isDarkTheme);
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
    if (state.config.speechEnabled) {
      await _flutterTts.speak(text);
    }
  }

  // Timer functionality
  void startTimer(int minutes) {
    _timerService.startTimer(minutes);
    _getTimerMotivation(minutes);
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
    updateExpression(RobotExpression.excited);
    _getTimerCompleteMessage();
  }

  // AI functionality
  Future<void> getAIResponse() async {
    emit(state.copyWith(isLoadingAI: true));

    try {
      final emotion = state.config.expression.name;
      final response = await _geminiService.getEmotionResponse(emotion);
      emit(state.copyWith(aiMessage: response, isLoadingAI: false));

      if (state.config.speechEnabled) {
        await _speak(response);
      }
    } catch (e) {
      emit(state.copyWith(isLoadingAI: false));
    }
  }

  Future<void> _getTimerMotivation(int minutes) async {
    try {
      final message = await _geminiService.getTimerMotivation(minutes);
      emit(state.copyWith(aiMessage: message));

      if (state.config.speechEnabled) {
        await _speak(message);
      }
    } catch (e) {
      // Fallback handled by service
    }
  }

  Future<void> _getTimerCompleteMessage() async {
    try {
      final message = await _geminiService.getTimerComplete();
      emit(state.copyWith(aiMessage: message));

      if (state.config.speechEnabled) {
        await _speak(message);
      }
    } catch (e) {
      // Fallback handled by service
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
  Future<void> close() {
    _flutterTts.stop();
    _timerService.dispose();
    _timerSubscription?.cancel();
    _timerStatusSubscription?.cancel();
    _timerCompleteSubscription?.cancel();
    WakelockPlus.disable();
    return super.close();
  }
}
