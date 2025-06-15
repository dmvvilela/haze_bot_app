// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'robot_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RobotConfig _$RobotConfigFromJson(Map<String, dynamic> json) {
  return _RobotConfig.fromJson(json);
}

/// @nodoc
mixin _$RobotConfig {
  RobotExpression get expression => throw _privateConstructorUsedError;
  @ColorConverter()
  Color get eyeColor => throw _privateConstructorUsedError;
  @ColorConverter()
  Color get mouthColor => throw _privateConstructorUsedError;
  FaceType get faceType => throw _privateConstructorUsedError;
  bool get speechEnabled => throw _privateConstructorUsedError;
  double get speechRate => throw _privateConstructorUsedError;
  double get speechPitch => throw _privateConstructorUsedError;

  /// Serializes this RobotConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RobotConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RobotConfigCopyWith<RobotConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RobotConfigCopyWith<$Res> {
  factory $RobotConfigCopyWith(
    RobotConfig value,
    $Res Function(RobotConfig) then,
  ) = _$RobotConfigCopyWithImpl<$Res, RobotConfig>;
  @useResult
  $Res call({
    RobotExpression expression,
    @ColorConverter() Color eyeColor,
    @ColorConverter() Color mouthColor,
    FaceType faceType,
    bool speechEnabled,
    double speechRate,
    double speechPitch,
  });
}

/// @nodoc
class _$RobotConfigCopyWithImpl<$Res, $Val extends RobotConfig>
    implements $RobotConfigCopyWith<$Res> {
  _$RobotConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RobotConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expression = null,
    Object? eyeColor = null,
    Object? mouthColor = null,
    Object? faceType = null,
    Object? speechEnabled = null,
    Object? speechRate = null,
    Object? speechPitch = null,
  }) {
    return _then(
      _value.copyWith(
            expression: null == expression
                ? _value.expression
                : expression // ignore: cast_nullable_to_non_nullable
                      as RobotExpression,
            eyeColor: null == eyeColor
                ? _value.eyeColor
                : eyeColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            mouthColor: null == mouthColor
                ? _value.mouthColor
                : mouthColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            faceType: null == faceType
                ? _value.faceType
                : faceType // ignore: cast_nullable_to_non_nullable
                      as FaceType,
            speechEnabled: null == speechEnabled
                ? _value.speechEnabled
                : speechEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            speechRate: null == speechRate
                ? _value.speechRate
                : speechRate // ignore: cast_nullable_to_non_nullable
                      as double,
            speechPitch: null == speechPitch
                ? _value.speechPitch
                : speechPitch // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RobotConfigImplCopyWith<$Res>
    implements $RobotConfigCopyWith<$Res> {
  factory _$$RobotConfigImplCopyWith(
    _$RobotConfigImpl value,
    $Res Function(_$RobotConfigImpl) then,
  ) = __$$RobotConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RobotExpression expression,
    @ColorConverter() Color eyeColor,
    @ColorConverter() Color mouthColor,
    FaceType faceType,
    bool speechEnabled,
    double speechRate,
    double speechPitch,
  });
}

/// @nodoc
class __$$RobotConfigImplCopyWithImpl<$Res>
    extends _$RobotConfigCopyWithImpl<$Res, _$RobotConfigImpl>
    implements _$$RobotConfigImplCopyWith<$Res> {
  __$$RobotConfigImplCopyWithImpl(
    _$RobotConfigImpl _value,
    $Res Function(_$RobotConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RobotConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expression = null,
    Object? eyeColor = null,
    Object? mouthColor = null,
    Object? faceType = null,
    Object? speechEnabled = null,
    Object? speechRate = null,
    Object? speechPitch = null,
  }) {
    return _then(
      _$RobotConfigImpl(
        expression: null == expression
            ? _value.expression
            : expression // ignore: cast_nullable_to_non_nullable
                  as RobotExpression,
        eyeColor: null == eyeColor
            ? _value.eyeColor
            : eyeColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        mouthColor: null == mouthColor
            ? _value.mouthColor
            : mouthColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        faceType: null == faceType
            ? _value.faceType
            : faceType // ignore: cast_nullable_to_non_nullable
                  as FaceType,
        speechEnabled: null == speechEnabled
            ? _value.speechEnabled
            : speechEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        speechRate: null == speechRate
            ? _value.speechRate
            : speechRate // ignore: cast_nullable_to_non_nullable
                  as double,
        speechPitch: null == speechPitch
            ? _value.speechPitch
            : speechPitch // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RobotConfigImpl implements _RobotConfig {
  const _$RobotConfigImpl({
    this.expression = RobotExpression.happy,
    @ColorConverter() this.eyeColor = Colors.cyan,
    @ColorConverter() this.mouthColor = Colors.pink,
    this.faceType = FaceType.classic,
    this.speechEnabled = false,
    this.speechRate = 1.0,
    this.speechPitch = 1.0,
  });

  factory _$RobotConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RobotConfigImplFromJson(json);

  @override
  @JsonKey()
  final RobotExpression expression;
  @override
  @JsonKey()
  @ColorConverter()
  final Color eyeColor;
  @override
  @JsonKey()
  @ColorConverter()
  final Color mouthColor;
  @override
  @JsonKey()
  final FaceType faceType;
  @override
  @JsonKey()
  final bool speechEnabled;
  @override
  @JsonKey()
  final double speechRate;
  @override
  @JsonKey()
  final double speechPitch;

  @override
  String toString() {
    return 'RobotConfig(expression: $expression, eyeColor: $eyeColor, mouthColor: $mouthColor, faceType: $faceType, speechEnabled: $speechEnabled, speechRate: $speechRate, speechPitch: $speechPitch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RobotConfigImpl &&
            (identical(other.expression, expression) ||
                other.expression == expression) &&
            (identical(other.eyeColor, eyeColor) ||
                other.eyeColor == eyeColor) &&
            (identical(other.mouthColor, mouthColor) ||
                other.mouthColor == mouthColor) &&
            (identical(other.faceType, faceType) ||
                other.faceType == faceType) &&
            (identical(other.speechEnabled, speechEnabled) ||
                other.speechEnabled == speechEnabled) &&
            (identical(other.speechRate, speechRate) ||
                other.speechRate == speechRate) &&
            (identical(other.speechPitch, speechPitch) ||
                other.speechPitch == speechPitch));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    expression,
    eyeColor,
    mouthColor,
    faceType,
    speechEnabled,
    speechRate,
    speechPitch,
  );

  /// Create a copy of RobotConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RobotConfigImplCopyWith<_$RobotConfigImpl> get copyWith =>
      __$$RobotConfigImplCopyWithImpl<_$RobotConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RobotConfigImplToJson(this);
  }
}

abstract class _RobotConfig implements RobotConfig {
  const factory _RobotConfig({
    final RobotExpression expression,
    @ColorConverter() final Color eyeColor,
    @ColorConverter() final Color mouthColor,
    final FaceType faceType,
    final bool speechEnabled,
    final double speechRate,
    final double speechPitch,
  }) = _$RobotConfigImpl;

  factory _RobotConfig.fromJson(Map<String, dynamic> json) =
      _$RobotConfigImpl.fromJson;

  @override
  RobotExpression get expression;
  @override
  @ColorConverter()
  Color get eyeColor;
  @override
  @ColorConverter()
  Color get mouthColor;
  @override
  FaceType get faceType;
  @override
  bool get speechEnabled;
  @override
  double get speechRate;
  @override
  double get speechPitch;

  /// Create a copy of RobotConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RobotConfigImplCopyWith<_$RobotConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
