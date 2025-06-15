import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:math' as math;

import '../models/robot_config.dart';
import '../i18n/strings.g.dart';

part 'robot_face_state.dart';
part 'robot_face_cubit.freezed.dart';

class RobotFaceCubit extends Cubit<RobotFaceState> {
  final FlutterTts _flutterTts = FlutterTts();

  RobotFaceCubit() : super(const RobotFaceState()) {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(state.config.language);
    await _flutterTts.setSpeechRate(state.config.speechRate);
    await _flutterTts.setPitch(state.config.speechPitch);
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

  @override
  Future<void> close() {
    _flutterTts.stop();
    return super.close();
  }
}
