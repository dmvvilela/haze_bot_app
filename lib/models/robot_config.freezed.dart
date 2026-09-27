// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'robot_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RobotConfig {

 RobotExpression get expression;@ColorConverter() Color get eyeColor;@ColorConverter() Color get mouthColor; bool get speechEnabled; HazeVoice get hazeVoice; bool get robotVoiceEnabled; bool get soundEnabled; double get speechRate; double get speechPitch; String get language; bool get isDarkTheme; bool get neverSleep;
/// Create a copy of RobotConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RobotConfigCopyWith<RobotConfig> get copyWith => _$RobotConfigCopyWithImpl<RobotConfig>(this as RobotConfig, _$identity);

  /// Serializes this RobotConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RobotConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RobotConfig&&(identical(other.expression, _this.expression) || other.expression == _this.expression)&&(identical(other.eyeColor, _this.eyeColor) || other.eyeColor == _this.eyeColor)&&(identical(other.mouthColor, _this.mouthColor) || other.mouthColor == _this.mouthColor)&&(identical(other.speechEnabled, _this.speechEnabled) || other.speechEnabled == _this.speechEnabled)&&(identical(other.hazeVoice, _this.hazeVoice) || other.hazeVoice == _this.hazeVoice)&&(identical(other.robotVoiceEnabled, _this.robotVoiceEnabled) || other.robotVoiceEnabled == _this.robotVoiceEnabled)&&(identical(other.soundEnabled, _this.soundEnabled) || other.soundEnabled == _this.soundEnabled)&&(identical(other.speechRate, _this.speechRate) || other.speechRate == _this.speechRate)&&(identical(other.speechPitch, _this.speechPitch) || other.speechPitch == _this.speechPitch)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.isDarkTheme, _this.isDarkTheme) || other.isDarkTheme == _this.isDarkTheme)&&(identical(other.neverSleep, _this.neverSleep) || other.neverSleep == _this.neverSleep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RobotConfig;
  return Object.hash(runtimeType,_this.expression,_this.eyeColor,_this.mouthColor,_this.speechEnabled,_this.hazeVoice,_this.robotVoiceEnabled,_this.soundEnabled,_this.speechRate,_this.speechPitch,_this.language,_this.isDarkTheme,_this.neverSleep);
}

@override
String toString() {
  final _this = this as RobotConfig;
  return 'RobotConfig(expression: ${_this.expression}, eyeColor: ${_this.eyeColor}, mouthColor: ${_this.mouthColor}, speechEnabled: ${_this.speechEnabled}, hazeVoice: ${_this.hazeVoice}, robotVoiceEnabled: ${_this.robotVoiceEnabled}, soundEnabled: ${_this.soundEnabled}, speechRate: ${_this.speechRate}, speechPitch: ${_this.speechPitch}, language: ${_this.language}, isDarkTheme: ${_this.isDarkTheme}, neverSleep: ${_this.neverSleep})';
}


}

/// @nodoc
abstract mixin class $RobotConfigCopyWith<$Res>  {
  factory $RobotConfigCopyWith(RobotConfig value, $Res Function(RobotConfig) _then) = _$RobotConfigCopyWithImpl;
@useResult
$Res call({
 RobotExpression expression,@ColorConverter() Color eyeColor,@ColorConverter() Color mouthColor, bool speechEnabled, HazeVoice hazeVoice, bool robotVoiceEnabled, bool soundEnabled, double speechRate, double speechPitch, String language, bool isDarkTheme, bool neverSleep
});




}
/// @nodoc
class _$RobotConfigCopyWithImpl<$Res>
    implements $RobotConfigCopyWith<$Res> {
  _$RobotConfigCopyWithImpl(this._self, this._then);

  final RobotConfig _self;
  final $Res Function(RobotConfig) _then;

/// Create a copy of RobotConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expression = null,Object? eyeColor = null,Object? mouthColor = null,Object? speechEnabled = null,Object? hazeVoice = null,Object? robotVoiceEnabled = null,Object? soundEnabled = null,Object? speechRate = null,Object? speechPitch = null,Object? language = null,Object? isDarkTheme = null,Object? neverSleep = null,}) {
  return _then(RobotConfig(
expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as RobotExpression,eyeColor: null == eyeColor ? _self.eyeColor : eyeColor // ignore: cast_nullable_to_non_nullable
as Color,mouthColor: null == mouthColor ? _self.mouthColor : mouthColor // ignore: cast_nullable_to_non_nullable
as Color,speechEnabled: null == speechEnabled ? _self.speechEnabled : speechEnabled // ignore: cast_nullable_to_non_nullable
as bool,hazeVoice: null == hazeVoice ? _self.hazeVoice : hazeVoice // ignore: cast_nullable_to_non_nullable
as HazeVoice,robotVoiceEnabled: null == robotVoiceEnabled ? _self.robotVoiceEnabled : robotVoiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,speechPitch: null == speechPitch ? _self.speechPitch : speechPitch // ignore: cast_nullable_to_non_nullable
as double,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isDarkTheme: null == isDarkTheme ? _self.isDarkTheme : isDarkTheme // ignore: cast_nullable_to_non_nullable
as bool,neverSleep: null == neverSleep ? _self.neverSleep : neverSleep // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RobotConfig].
extension RobotConfigPatterns on RobotConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RobotConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RobotConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RobotConfig value)  $default,){
final _that = this;
switch (_that) {
case _RobotConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RobotConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RobotConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RobotExpression expression, @ColorConverter()  Color eyeColor, @ColorConverter()  Color mouthColor,  bool speechEnabled,  HazeVoice hazeVoice,  bool robotVoiceEnabled,  bool soundEnabled,  double speechRate,  double speechPitch,  String language,  bool isDarkTheme,  bool neverSleep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RobotConfig() when $default != null:
return $default(_that.expression,_that.eyeColor,_that.mouthColor,_that.speechEnabled,_that.hazeVoice,_that.robotVoiceEnabled,_that.soundEnabled,_that.speechRate,_that.speechPitch,_that.language,_that.isDarkTheme,_that.neverSleep);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RobotExpression expression, @ColorConverter()  Color eyeColor, @ColorConverter()  Color mouthColor,  bool speechEnabled,  HazeVoice hazeVoice,  bool robotVoiceEnabled,  bool soundEnabled,  double speechRate,  double speechPitch,  String language,  bool isDarkTheme,  bool neverSleep)  $default,) {final _that = this;
switch (_that) {
case _RobotConfig():
return $default(_that.expression,_that.eyeColor,_that.mouthColor,_that.speechEnabled,_that.hazeVoice,_that.robotVoiceEnabled,_that.soundEnabled,_that.speechRate,_that.speechPitch,_that.language,_that.isDarkTheme,_that.neverSleep);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RobotExpression expression, @ColorConverter()  Color eyeColor, @ColorConverter()  Color mouthColor,  bool speechEnabled,  HazeVoice hazeVoice,  bool robotVoiceEnabled,  bool soundEnabled,  double speechRate,  double speechPitch,  String language,  bool isDarkTheme,  bool neverSleep)?  $default,) {final _that = this;
switch (_that) {
case _RobotConfig() when $default != null:
return $default(_that.expression,_that.eyeColor,_that.mouthColor,_that.speechEnabled,_that.hazeVoice,_that.robotVoiceEnabled,_that.soundEnabled,_that.speechRate,_that.speechPitch,_that.language,_that.isDarkTheme,_that.neverSleep);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RobotConfig implements RobotConfig {
  const _RobotConfig({this.expression = RobotExpression.happy, @ColorConverter() this.eyeColor = Colors.cyan, @ColorConverter() this.mouthColor = Colors.pink, this.speechEnabled = false, this.hazeVoice = HazeVoice.compactWit, this.robotVoiceEnabled = true, this.soundEnabled = true, this.speechRate = 0.55, this.speechPitch = 0.95, this.language = 'en-US', this.isDarkTheme = true, this.neverSleep = false});
  factory _RobotConfig.fromJson(Map<String, dynamic> json) => _$RobotConfigFromJson(json);

@override@JsonKey() final  RobotExpression expression;
@override@JsonKey()@ColorConverter() final  Color eyeColor;
@override@JsonKey()@ColorConverter() final  Color mouthColor;
@override@JsonKey() final  bool speechEnabled;
@override@JsonKey() final  HazeVoice hazeVoice;
@override@JsonKey() final  bool robotVoiceEnabled;
@override@JsonKey() final  bool soundEnabled;
@override@JsonKey() final  double speechRate;
@override@JsonKey() final  double speechPitch;
@override@JsonKey() final  String language;
@override@JsonKey() final  bool isDarkTheme;
@override@JsonKey() final  bool neverSleep;

/// Create a copy of RobotConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RobotConfigCopyWith<_RobotConfig> get copyWith => __$RobotConfigCopyWithImpl<_RobotConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RobotConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RobotConfig&&(identical(other.expression, expression) || other.expression == expression)&&(identical(other.eyeColor, eyeColor) || other.eyeColor == eyeColor)&&(identical(other.mouthColor, mouthColor) || other.mouthColor == mouthColor)&&(identical(other.speechEnabled, speechEnabled) || other.speechEnabled == speechEnabled)&&(identical(other.hazeVoice, hazeVoice) || other.hazeVoice == hazeVoice)&&(identical(other.robotVoiceEnabled, robotVoiceEnabled) || other.robotVoiceEnabled == robotVoiceEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate)&&(identical(other.speechPitch, speechPitch) || other.speechPitch == speechPitch)&&(identical(other.language, language) || other.language == language)&&(identical(other.isDarkTheme, isDarkTheme) || other.isDarkTheme == isDarkTheme)&&(identical(other.neverSleep, neverSleep) || other.neverSleep == neverSleep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,expression,eyeColor,mouthColor,speechEnabled,hazeVoice,robotVoiceEnabled,soundEnabled,speechRate,speechPitch,language,isDarkTheme,neverSleep);
}

@override
String toString() {
    return 'RobotConfig(expression: $expression, eyeColor: $eyeColor, mouthColor: $mouthColor, speechEnabled: $speechEnabled, hazeVoice: $hazeVoice, robotVoiceEnabled: $robotVoiceEnabled, soundEnabled: $soundEnabled, speechRate: $speechRate, speechPitch: $speechPitch, language: $language, isDarkTheme: $isDarkTheme, neverSleep: $neverSleep)';
}


}

/// @nodoc
abstract mixin class _$RobotConfigCopyWith<$Res> implements $RobotConfigCopyWith<$Res> {
  factory _$RobotConfigCopyWith(_RobotConfig value, $Res Function(_RobotConfig) _then) = __$RobotConfigCopyWithImpl;
@override @useResult
$Res call({
 RobotExpression expression,@ColorConverter() Color eyeColor,@ColorConverter() Color mouthColor, bool speechEnabled, HazeVoice hazeVoice, bool robotVoiceEnabled, bool soundEnabled, double speechRate, double speechPitch, String language, bool isDarkTheme, bool neverSleep
});




}
/// @nodoc
class __$RobotConfigCopyWithImpl<$Res>
    implements _$RobotConfigCopyWith<$Res> {
  __$RobotConfigCopyWithImpl(this._self, this._then);

  final _RobotConfig _self;
  final $Res Function(_RobotConfig) _then;

/// Create a copy of RobotConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expression = null,Object? eyeColor = null,Object? mouthColor = null,Object? speechEnabled = null,Object? hazeVoice = null,Object? robotVoiceEnabled = null,Object? soundEnabled = null,Object? speechRate = null,Object? speechPitch = null,Object? language = null,Object? isDarkTheme = null,Object? neverSleep = null,}) {
  return _then(_RobotConfig(
expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as RobotExpression,eyeColor: null == eyeColor ? _self.eyeColor : eyeColor // ignore: cast_nullable_to_non_nullable
as Color,mouthColor: null == mouthColor ? _self.mouthColor : mouthColor // ignore: cast_nullable_to_non_nullable
as Color,speechEnabled: null == speechEnabled ? _self.speechEnabled : speechEnabled // ignore: cast_nullable_to_non_nullable
as bool,hazeVoice: null == hazeVoice ? _self.hazeVoice : hazeVoice // ignore: cast_nullable_to_non_nullable
as HazeVoice,robotVoiceEnabled: null == robotVoiceEnabled ? _self.robotVoiceEnabled : robotVoiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,speechPitch: null == speechPitch ? _self.speechPitch : speechPitch // ignore: cast_nullable_to_non_nullable
as double,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isDarkTheme: null == isDarkTheme ? _self.isDarkTheme : isDarkTheme // ignore: cast_nullable_to_non_nullable
as bool,neverSleep: null == neverSleep ? _self.neverSleep : neverSleep // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
