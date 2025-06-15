// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'robot_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RobotConfigImpl _$$RobotConfigImplFromJson(Map<String, dynamic> json) =>
    _$RobotConfigImpl(
      expression:
          $enumDecodeNullable(_$RobotExpressionEnumMap, json['expression']) ??
          RobotExpression.happy,
      eyeColor: json['eyeColor'] == null
          ? Colors.cyan
          : const ColorConverter().fromJson((json['eyeColor'] as num).toInt()),
      mouthColor: json['mouthColor'] == null
          ? Colors.pink
          : const ColorConverter().fromJson(
              (json['mouthColor'] as num).toInt(),
            ),
      faceType:
          $enumDecodeNullable(_$FaceTypeEnumMap, json['faceType']) ??
          FaceType.classic,
      speechEnabled: json['speechEnabled'] as bool? ?? false,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.7,
      speechPitch: (json['speechPitch'] as num?)?.toDouble() ?? 1.2,
      language: json['language'] as String? ?? 'en-US',
      isDarkTheme: json['isDarkTheme'] as bool? ?? true,
    );

Map<String, dynamic> _$$RobotConfigImplToJson(_$RobotConfigImpl instance) =>
    <String, dynamic>{
      'expression': _$RobotExpressionEnumMap[instance.expression]!,
      'eyeColor': const ColorConverter().toJson(instance.eyeColor),
      'mouthColor': const ColorConverter().toJson(instance.mouthColor),
      'faceType': _$FaceTypeEnumMap[instance.faceType]!,
      'speechEnabled': instance.speechEnabled,
      'speechRate': instance.speechRate,
      'speechPitch': instance.speechPitch,
      'language': instance.language,
      'isDarkTheme': instance.isDarkTheme,
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
};

const _$FaceTypeEnumMap = {
  FaceType.classic: 'classic',
  FaceType.looi: 'looi',
  FaceType.minimal: 'minimal',
  FaceType.bean: 'bean',
};
