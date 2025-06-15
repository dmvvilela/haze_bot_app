import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'robot_config.freezed.dart';
part 'robot_config.g.dart';

@freezed
class RobotConfig with _$RobotConfig {
  const factory RobotConfig({
    @Default(RobotExpression.happy) RobotExpression expression,
    @Default(Colors.cyan) @ColorConverter() Color eyeColor,
    @Default(Colors.pink) @ColorConverter() Color mouthColor,
    @Default(FaceType.classic) FaceType faceType,
    @Default(false) bool speechEnabled,
    @Default(1.0) double speechRate,
    @Default(1.0) double speechPitch,
    @Default('en-US') String language,
    @Default(true) bool isDarkTheme,
  }) = _RobotConfig;

  factory RobotConfig.fromJson(Map<String, dynamic> json) => _$RobotConfigFromJson(json);
}

enum RobotExpression { happy, surprised, sleepy, excited, confused, love, angry, winking }

enum FaceType { classic, looi, minimal, bean }

// Custom color converter for Freezed
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

extension RobotExpressionExtension on RobotExpression {
  String get displayName {
    switch (this) {
      case RobotExpression.happy:
        return 'Happy';
      case RobotExpression.surprised:
        return 'Surprised';
      case RobotExpression.sleepy:
        return 'Sleepy';
      case RobotExpression.excited:
        return 'Excited';
      case RobotExpression.confused:
        return 'Confused';
      case RobotExpression.love:
        return 'Love';
      case RobotExpression.angry:
        return 'Angry';
      case RobotExpression.winking:
        return 'Winking';
    }
  }

  String get speechText {
    // This will be replaced with proper translations in the UI layer
    switch (this) {
      case RobotExpression.happy:
        return 'I am so happy!';
      case RobotExpression.surprised:
        return 'Oh wow! That surprised me!';
      case RobotExpression.sleepy:
        return 'I am feeling sleepy...';
      case RobotExpression.excited:
        return 'This is so exciting!';
      case RobotExpression.confused:
        return 'Hmm, I am confused...';
      case RobotExpression.love:
        return 'I love you!';
      case RobotExpression.angry:
        return 'I am not happy about this!';
      case RobotExpression.winking:
        return 'Wink wink!';
    }
  }
}

extension FaceTypeExtension on FaceType {
  String get displayName {
    switch (this) {
      case FaceType.classic:
        return 'Classic';
      case FaceType.looi:
        return 'LOOI Style';
      case FaceType.minimal:
        return 'Minimal';
      case FaceType.bean:
        return 'Bean Face';
    }
  }

  String get description {
    switch (this) {
      case FaceType.classic:
        return 'Full circular eyes with expressive pupils';
      case FaceType.looi:
        return 'LOOI-inspired eyes with eyebrows';
      case FaceType.minimal:
        return 'Simple and clean design';
      case FaceType.bean:
        return 'Fall Guys inspired vertical bean eyes';
    }
  }
}
