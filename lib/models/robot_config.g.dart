// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'robot_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RobotConfig _$RobotConfigFromJson(Map<String, dynamic> json) => _RobotConfig(
  expression:
      $enumDecodeNullable(_$RobotExpressionEnumMap, json['expression']) ??
      RobotExpression.happy,
  eyeColor: json['eyeColor'] == null
      ? Colors.cyan
      : const ColorConverter().fromJson((json['eyeColor'] as num).toInt()),
  mouthColor: json['mouthColor'] == null
      ? Colors.pink
      : const ColorConverter().fromJson((json['mouthColor'] as num).toInt()),
  speechEnabled: json['speechEnabled'] as bool? ?? false,
  hazeVoice:
      $enumDecodeNullable(_$HazeVoiceEnumMap, json['hazeVoice']) ??
      HazeVoice.compactWit,
  robotVoiceEnabled: json['robotVoiceEnabled'] as bool? ?? true,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.55,
  speechPitch: (json['speechPitch'] as num?)?.toDouble() ?? 0.95,
  language: json['language'] as String? ?? 'en-US',
  isDarkTheme: json['isDarkTheme'] as bool? ?? true,
  neverSleep: json['neverSleep'] as bool? ?? false,
);

Map<String, dynamic> _$RobotConfigToJson(_RobotConfig instance) =>
    <String, dynamic>{
      'expression': _$RobotExpressionEnumMap[instance.expression]!,
      'eyeColor': const ColorConverter().toJson(instance.eyeColor),
      'mouthColor': const ColorConverter().toJson(instance.mouthColor),
      'speechEnabled': instance.speechEnabled,
      'hazeVoice': _$HazeVoiceEnumMap[instance.hazeVoice]!,
      'robotVoiceEnabled': instance.robotVoiceEnabled,
      'soundEnabled': instance.soundEnabled,
      'speechRate': instance.speechRate,
      'speechPitch': instance.speechPitch,
      'language': instance.language,
      'isDarkTheme': instance.isDarkTheme,
      'neverSleep': instance.neverSleep,
    };

const _$RobotExpressionEnumMap = {
  RobotExpression.happy: 'happy',
  RobotExpression.surprised: 'surprised',
  RobotExpression.sleepy: 'sleepy',
  RobotExpression.excited: 'excited',
  RobotExpression.confused: 'confused',
  RobotExpression.love: 'love',
  RobotExpression.angry: 'angry',
  RobotExpression.winking: 'winking',
  RobotExpression.sad: 'sad',
  RobotExpression.scared: 'scared',
};

const _$HazeVoiceEnumMap = {
  HazeVoice.compactWit: 'compactWit',
  HazeVoice.warmCircuit: 'warmCircuit',
  HazeVoice.cheekyUnit: 'cheekyUnit',
  HazeVoice.maleBrightCircuit: 'maleBrightCircuit',
  HazeVoice.maleWarmUnit: 'maleWarmUnit',
  HazeVoice.maleCheekyBot: 'maleCheekyBot',
};
