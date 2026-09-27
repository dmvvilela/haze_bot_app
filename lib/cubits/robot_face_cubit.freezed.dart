// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'robot_face_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RobotFaceState {

 RobotConfig get config; bool get isPressed; bool get isBlinking; bool get showControls; bool get isTimerRunning; int get timerSeconds; String get aiMessage; String get chemistryReaction; bool get isLoadingAI; bool get isSpeaking; bool get showChatComposer; MimicStatus get mimicStatus; bool get keepScreenAwake; BrainStatus get brainStatus; int get downloadProgress; AiConsent get aiConsent; HazePersonality get personality; List<TtsVoiceOption> get ttsVoiceOptions; String? get selectedTtsVoiceId;/// Where the user's finger is on the face (normalized -1..1 from center),
/// while they're dragging. The eyes follow it; null returns to idle gaze.
 Offset? get lookTarget;
/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RobotFaceStateCopyWith<RobotFaceState> get copyWith => _$RobotFaceStateCopyWithImpl<RobotFaceState>(this as RobotFaceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RobotFaceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RobotFaceState&&(identical(other.config, _this.config) || other.config == _this.config)&&(identical(other.isPressed, _this.isPressed) || other.isPressed == _this.isPressed)&&(identical(other.isBlinking, _this.isBlinking) || other.isBlinking == _this.isBlinking)&&(identical(other.showControls, _this.showControls) || other.showControls == _this.showControls)&&(identical(other.isTimerRunning, _this.isTimerRunning) || other.isTimerRunning == _this.isTimerRunning)&&(identical(other.timerSeconds, _this.timerSeconds) || other.timerSeconds == _this.timerSeconds)&&(identical(other.aiMessage, _this.aiMessage) || other.aiMessage == _this.aiMessage)&&(identical(other.chemistryReaction, _this.chemistryReaction) || other.chemistryReaction == _this.chemistryReaction)&&(identical(other.isLoadingAI, _this.isLoadingAI) || other.isLoadingAI == _this.isLoadingAI)&&(identical(other.isSpeaking, _this.isSpeaking) || other.isSpeaking == _this.isSpeaking)&&(identical(other.showChatComposer, _this.showChatComposer) || other.showChatComposer == _this.showChatComposer)&&(identical(other.mimicStatus, _this.mimicStatus) || other.mimicStatus == _this.mimicStatus)&&(identical(other.keepScreenAwake, _this.keepScreenAwake) || other.keepScreenAwake == _this.keepScreenAwake)&&(identical(other.brainStatus, _this.brainStatus) || other.brainStatus == _this.brainStatus)&&(identical(other.downloadProgress, _this.downloadProgress) || other.downloadProgress == _this.downloadProgress)&&(identical(other.aiConsent, _this.aiConsent) || other.aiConsent == _this.aiConsent)&&(identical(other.personality, _this.personality) || other.personality == _this.personality)&&const DeepCollectionEquality().equals(other.ttsVoiceOptions, _this.ttsVoiceOptions)&&(identical(other.selectedTtsVoiceId, _this.selectedTtsVoiceId) || other.selectedTtsVoiceId == _this.selectedTtsVoiceId)&&(identical(other.lookTarget, _this.lookTarget) || other.lookTarget == _this.lookTarget));
}


@override
int get hashCode {
  final _this = this as RobotFaceState;
  return Object.hashAll([runtimeType,_this.config,_this.isPressed,_this.isBlinking,_this.showControls,_this.isTimerRunning,_this.timerSeconds,_this.aiMessage,_this.chemistryReaction,_this.isLoadingAI,_this.isSpeaking,_this.showChatComposer,_this.mimicStatus,_this.keepScreenAwake,_this.brainStatus,_this.downloadProgress,_this.aiConsent,_this.personality,const DeepCollectionEquality().hash(_this.ttsVoiceOptions),_this.selectedTtsVoiceId,_this.lookTarget]);
}

@override
String toString() {
  final _this = this as RobotFaceState;
  return 'RobotFaceState(config: ${_this.config}, isPressed: ${_this.isPressed}, isBlinking: ${_this.isBlinking}, showControls: ${_this.showControls}, isTimerRunning: ${_this.isTimerRunning}, timerSeconds: ${_this.timerSeconds}, aiMessage: ${_this.aiMessage}, chemistryReaction: ${_this.chemistryReaction}, isLoadingAI: ${_this.isLoadingAI}, isSpeaking: ${_this.isSpeaking}, showChatComposer: ${_this.showChatComposer}, mimicStatus: ${_this.mimicStatus}, keepScreenAwake: ${_this.keepScreenAwake}, brainStatus: ${_this.brainStatus}, downloadProgress: ${_this.downloadProgress}, aiConsent: ${_this.aiConsent}, personality: ${_this.personality}, ttsVoiceOptions: ${_this.ttsVoiceOptions}, selectedTtsVoiceId: ${_this.selectedTtsVoiceId}, lookTarget: ${_this.lookTarget})';
}


}

/// @nodoc
abstract mixin class $RobotFaceStateCopyWith<$Res>  {
  factory $RobotFaceStateCopyWith(RobotFaceState value, $Res Function(RobotFaceState) _then) = _$RobotFaceStateCopyWithImpl;
@useResult
$Res call({
 RobotConfig config, bool isPressed, bool isBlinking, bool showControls, bool isTimerRunning, int timerSeconds, String aiMessage, String chemistryReaction, bool isLoadingAI, bool isSpeaking, bool showChatComposer, MimicStatus mimicStatus, bool keepScreenAwake, BrainStatus brainStatus, int downloadProgress, AiConsent aiConsent, HazePersonality personality, List<TtsVoiceOption> ttsVoiceOptions, String? selectedTtsVoiceId, Offset? lookTarget
});


$RobotConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$RobotFaceStateCopyWithImpl<$Res>
    implements $RobotFaceStateCopyWith<$Res> {
  _$RobotFaceStateCopyWithImpl(this._self, this._then);

  final RobotFaceState _self;
  final $Res Function(RobotFaceState) _then;

/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? config = null,Object? isPressed = null,Object? isBlinking = null,Object? showControls = null,Object? isTimerRunning = null,Object? timerSeconds = null,Object? aiMessage = null,Object? chemistryReaction = null,Object? isLoadingAI = null,Object? isSpeaking = null,Object? showChatComposer = null,Object? mimicStatus = null,Object? keepScreenAwake = null,Object? brainStatus = null,Object? downloadProgress = null,Object? aiConsent = null,Object? personality = null,Object? ttsVoiceOptions = null,Object? selectedTtsVoiceId = freezed,Object? lookTarget = freezed,}) {
  return _then(RobotFaceState(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as RobotConfig,isPressed: null == isPressed ? _self.isPressed : isPressed // ignore: cast_nullable_to_non_nullable
as bool,isBlinking: null == isBlinking ? _self.isBlinking : isBlinking // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,isTimerRunning: null == isTimerRunning ? _self.isTimerRunning : isTimerRunning // ignore: cast_nullable_to_non_nullable
as bool,timerSeconds: null == timerSeconds ? _self.timerSeconds : timerSeconds // ignore: cast_nullable_to_non_nullable
as int,aiMessage: null == aiMessage ? _self.aiMessage : aiMessage // ignore: cast_nullable_to_non_nullable
as String,chemistryReaction: null == chemistryReaction ? _self.chemistryReaction : chemistryReaction // ignore: cast_nullable_to_non_nullable
as String,isLoadingAI: null == isLoadingAI ? _self.isLoadingAI : isLoadingAI // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,showChatComposer: null == showChatComposer ? _self.showChatComposer : showChatComposer // ignore: cast_nullable_to_non_nullable
as bool,mimicStatus: null == mimicStatus ? _self.mimicStatus : mimicStatus // ignore: cast_nullable_to_non_nullable
as MimicStatus,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,brainStatus: null == brainStatus ? _self.brainStatus : brainStatus // ignore: cast_nullable_to_non_nullable
as BrainStatus,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as int,aiConsent: null == aiConsent ? _self.aiConsent : aiConsent // ignore: cast_nullable_to_non_nullable
as AiConsent,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as HazePersonality,ttsVoiceOptions: null == ttsVoiceOptions ? _self.ttsVoiceOptions : ttsVoiceOptions // ignore: cast_nullable_to_non_nullable
as List<TtsVoiceOption>,selectedTtsVoiceId: freezed == selectedTtsVoiceId ? _self.selectedTtsVoiceId : selectedTtsVoiceId // ignore: cast_nullable_to_non_nullable
as String?,lookTarget: freezed == lookTarget ? _self.lookTarget : lookTarget // ignore: cast_nullable_to_non_nullable
as Offset?,
  ));
}
/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RobotConfigCopyWith<$Res> get config {
  
  return $RobotConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [RobotFaceState].
extension RobotFaceStatePatterns on RobotFaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RobotFaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RobotFaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RobotFaceState value)  $default,){
final _that = this;
switch (_that) {
case _RobotFaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RobotFaceState value)?  $default,){
final _that = this;
switch (_that) {
case _RobotFaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RobotConfig config,  bool isPressed,  bool isBlinking,  bool showControls,  bool isTimerRunning,  int timerSeconds,  String aiMessage,  String chemistryReaction,  bool isLoadingAI,  bool isSpeaking,  bool showChatComposer,  MimicStatus mimicStatus,  bool keepScreenAwake,  BrainStatus brainStatus,  int downloadProgress,  AiConsent aiConsent,  HazePersonality personality,  List<TtsVoiceOption> ttsVoiceOptions,  String? selectedTtsVoiceId,  Offset? lookTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RobotFaceState() when $default != null:
return $default(_that.config,_that.isPressed,_that.isBlinking,_that.showControls,_that.isTimerRunning,_that.timerSeconds,_that.aiMessage,_that.chemistryReaction,_that.isLoadingAI,_that.isSpeaking,_that.showChatComposer,_that.mimicStatus,_that.keepScreenAwake,_that.brainStatus,_that.downloadProgress,_that.aiConsent,_that.personality,_that.ttsVoiceOptions,_that.selectedTtsVoiceId,_that.lookTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RobotConfig config,  bool isPressed,  bool isBlinking,  bool showControls,  bool isTimerRunning,  int timerSeconds,  String aiMessage,  String chemistryReaction,  bool isLoadingAI,  bool isSpeaking,  bool showChatComposer,  MimicStatus mimicStatus,  bool keepScreenAwake,  BrainStatus brainStatus,  int downloadProgress,  AiConsent aiConsent,  HazePersonality personality,  List<TtsVoiceOption> ttsVoiceOptions,  String? selectedTtsVoiceId,  Offset? lookTarget)  $default,) {final _that = this;
switch (_that) {
case _RobotFaceState():
return $default(_that.config,_that.isPressed,_that.isBlinking,_that.showControls,_that.isTimerRunning,_that.timerSeconds,_that.aiMessage,_that.chemistryReaction,_that.isLoadingAI,_that.isSpeaking,_that.showChatComposer,_that.mimicStatus,_that.keepScreenAwake,_that.brainStatus,_that.downloadProgress,_that.aiConsent,_that.personality,_that.ttsVoiceOptions,_that.selectedTtsVoiceId,_that.lookTarget);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RobotConfig config,  bool isPressed,  bool isBlinking,  bool showControls,  bool isTimerRunning,  int timerSeconds,  String aiMessage,  String chemistryReaction,  bool isLoadingAI,  bool isSpeaking,  bool showChatComposer,  MimicStatus mimicStatus,  bool keepScreenAwake,  BrainStatus brainStatus,  int downloadProgress,  AiConsent aiConsent,  HazePersonality personality,  List<TtsVoiceOption> ttsVoiceOptions,  String? selectedTtsVoiceId,  Offset? lookTarget)?  $default,) {final _that = this;
switch (_that) {
case _RobotFaceState() when $default != null:
return $default(_that.config,_that.isPressed,_that.isBlinking,_that.showControls,_that.isTimerRunning,_that.timerSeconds,_that.aiMessage,_that.chemistryReaction,_that.isLoadingAI,_that.isSpeaking,_that.showChatComposer,_that.mimicStatus,_that.keepScreenAwake,_that.brainStatus,_that.downloadProgress,_that.aiConsent,_that.personality,_that.ttsVoiceOptions,_that.selectedTtsVoiceId,_that.lookTarget);case _:
  return null;

}
}

}

/// @nodoc


class _RobotFaceState implements RobotFaceState {
  const _RobotFaceState({this.config = const RobotConfig(), this.isPressed = false, this.isBlinking = false, this.showControls = true, this.isTimerRunning = false, this.timerSeconds = 0, this.aiMessage = '', this.chemistryReaction = '', this.isLoadingAI = false, this.isSpeaking = false, this.showChatComposer = false, this.mimicStatus = MimicStatus.idle, this.keepScreenAwake = false, this.brainStatus = BrainStatus.idle, this.downloadProgress = 0, this.aiConsent = AiConsent.unknown, this.personality = HazePersonality.playful,  List<TtsVoiceOption> ttsVoiceOptions = const [], this.selectedTtsVoiceId, this.lookTarget}): _ttsVoiceOptions = ttsVoiceOptions;
  

@override@JsonKey() final  RobotConfig config;
@override@JsonKey() final  bool isPressed;
@override@JsonKey() final  bool isBlinking;
@override@JsonKey() final  bool showControls;
@override@JsonKey() final  bool isTimerRunning;
@override@JsonKey() final  int timerSeconds;
@override@JsonKey() final  String aiMessage;
@override@JsonKey() final  String chemistryReaction;
@override@JsonKey() final  bool isLoadingAI;
@override@JsonKey() final  bool isSpeaking;
@override@JsonKey() final  bool showChatComposer;
@override@JsonKey() final  MimicStatus mimicStatus;
@override@JsonKey() final  bool keepScreenAwake;
@override@JsonKey() final  BrainStatus brainStatus;
@override@JsonKey() final  int downloadProgress;
@override@JsonKey() final  AiConsent aiConsent;
@override@JsonKey() final  HazePersonality personality;
 final  List<TtsVoiceOption> _ttsVoiceOptions;
@override@JsonKey() List<TtsVoiceOption> get ttsVoiceOptions {
  if (_ttsVoiceOptions is EqualUnmodifiableListView) return _ttsVoiceOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ttsVoiceOptions);
}

@override final  String? selectedTtsVoiceId;
/// Where the user's finger is on the face (normalized -1..1 from center),
/// while they're dragging. The eyes follow it; null returns to idle gaze.
@override final  Offset? lookTarget;

/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RobotFaceStateCopyWith<_RobotFaceState> get copyWith => __$RobotFaceStateCopyWithImpl<_RobotFaceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RobotFaceState&&(identical(other.config, config) || other.config == config)&&(identical(other.isPressed, isPressed) || other.isPressed == isPressed)&&(identical(other.isBlinking, isBlinking) || other.isBlinking == isBlinking)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.isTimerRunning, isTimerRunning) || other.isTimerRunning == isTimerRunning)&&(identical(other.timerSeconds, timerSeconds) || other.timerSeconds == timerSeconds)&&(identical(other.aiMessage, aiMessage) || other.aiMessage == aiMessage)&&(identical(other.chemistryReaction, chemistryReaction) || other.chemistryReaction == chemistryReaction)&&(identical(other.isLoadingAI, isLoadingAI) || other.isLoadingAI == isLoadingAI)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.showChatComposer, showChatComposer) || other.showChatComposer == showChatComposer)&&(identical(other.mimicStatus, mimicStatus) || other.mimicStatus == mimicStatus)&&(identical(other.keepScreenAwake, keepScreenAwake) || other.keepScreenAwake == keepScreenAwake)&&(identical(other.brainStatus, brainStatus) || other.brainStatus == brainStatus)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.aiConsent, aiConsent) || other.aiConsent == aiConsent)&&(identical(other.personality, personality) || other.personality == personality)&&const DeepCollectionEquality().equals(other.ttsVoiceOptions, _ttsVoiceOptions)&&(identical(other.selectedTtsVoiceId, selectedTtsVoiceId) || other.selectedTtsVoiceId == selectedTtsVoiceId)&&(identical(other.lookTarget, lookTarget) || other.lookTarget == lookTarget));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,config,isPressed,isBlinking,showControls,isTimerRunning,timerSeconds,aiMessage,chemistryReaction,isLoadingAI,isSpeaking,showChatComposer,mimicStatus,keepScreenAwake,brainStatus,downloadProgress,aiConsent,personality,const DeepCollectionEquality().hash(_ttsVoiceOptions),selectedTtsVoiceId,lookTarget]);
}

@override
String toString() {
    return 'RobotFaceState(config: $config, isPressed: $isPressed, isBlinking: $isBlinking, showControls: $showControls, isTimerRunning: $isTimerRunning, timerSeconds: $timerSeconds, aiMessage: $aiMessage, chemistryReaction: $chemistryReaction, isLoadingAI: $isLoadingAI, isSpeaking: $isSpeaking, showChatComposer: $showChatComposer, mimicStatus: $mimicStatus, keepScreenAwake: $keepScreenAwake, brainStatus: $brainStatus, downloadProgress: $downloadProgress, aiConsent: $aiConsent, personality: $personality, ttsVoiceOptions: $ttsVoiceOptions, selectedTtsVoiceId: $selectedTtsVoiceId, lookTarget: $lookTarget)';
}


}

/// @nodoc
abstract mixin class _$RobotFaceStateCopyWith<$Res> implements $RobotFaceStateCopyWith<$Res> {
  factory _$RobotFaceStateCopyWith(_RobotFaceState value, $Res Function(_RobotFaceState) _then) = __$RobotFaceStateCopyWithImpl;
@override @useResult
$Res call({
 RobotConfig config, bool isPressed, bool isBlinking, bool showControls, bool isTimerRunning, int timerSeconds, String aiMessage, String chemistryReaction, bool isLoadingAI, bool isSpeaking, bool showChatComposer, MimicStatus mimicStatus, bool keepScreenAwake, BrainStatus brainStatus, int downloadProgress, AiConsent aiConsent, HazePersonality personality, List<TtsVoiceOption> ttsVoiceOptions, String? selectedTtsVoiceId, Offset? lookTarget
});


@override $RobotConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$RobotFaceStateCopyWithImpl<$Res>
    implements _$RobotFaceStateCopyWith<$Res> {
  __$RobotFaceStateCopyWithImpl(this._self, this._then);

  final _RobotFaceState _self;
  final $Res Function(_RobotFaceState) _then;

/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? config = null,Object? isPressed = null,Object? isBlinking = null,Object? showControls = null,Object? isTimerRunning = null,Object? timerSeconds = null,Object? aiMessage = null,Object? chemistryReaction = null,Object? isLoadingAI = null,Object? isSpeaking = null,Object? showChatComposer = null,Object? mimicStatus = null,Object? keepScreenAwake = null,Object? brainStatus = null,Object? downloadProgress = null,Object? aiConsent = null,Object? personality = null,Object? ttsVoiceOptions = null,Object? selectedTtsVoiceId = freezed,Object? lookTarget = freezed,}) {
  return _then(_RobotFaceState(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as RobotConfig,isPressed: null == isPressed ? _self.isPressed : isPressed // ignore: cast_nullable_to_non_nullable
as bool,isBlinking: null == isBlinking ? _self.isBlinking : isBlinking // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,isTimerRunning: null == isTimerRunning ? _self.isTimerRunning : isTimerRunning // ignore: cast_nullable_to_non_nullable
as bool,timerSeconds: null == timerSeconds ? _self.timerSeconds : timerSeconds // ignore: cast_nullable_to_non_nullable
as int,aiMessage: null == aiMessage ? _self.aiMessage : aiMessage // ignore: cast_nullable_to_non_nullable
as String,chemistryReaction: null == chemistryReaction ? _self.chemistryReaction : chemistryReaction // ignore: cast_nullable_to_non_nullable
as String,isLoadingAI: null == isLoadingAI ? _self.isLoadingAI : isLoadingAI // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,showChatComposer: null == showChatComposer ? _self.showChatComposer : showChatComposer // ignore: cast_nullable_to_non_nullable
as bool,mimicStatus: null == mimicStatus ? _self.mimicStatus : mimicStatus // ignore: cast_nullable_to_non_nullable
as MimicStatus,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,brainStatus: null == brainStatus ? _self.brainStatus : brainStatus // ignore: cast_nullable_to_non_nullable
as BrainStatus,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as int,aiConsent: null == aiConsent ? _self.aiConsent : aiConsent // ignore: cast_nullable_to_non_nullable
as AiConsent,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as HazePersonality,ttsVoiceOptions: null == ttsVoiceOptions ? _self._ttsVoiceOptions : ttsVoiceOptions // ignore: cast_nullable_to_non_nullable
as List<TtsVoiceOption>,selectedTtsVoiceId: freezed == selectedTtsVoiceId ? _self.selectedTtsVoiceId : selectedTtsVoiceId // ignore: cast_nullable_to_non_nullable
as String?,lookTarget: freezed == lookTarget ? _self.lookTarget : lookTarget // ignore: cast_nullable_to_non_nullable
as Offset?,
  ));
}

/// Create a copy of RobotFaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RobotConfigCopyWith<$Res> get config {
  
  return $RobotConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

// dart format on
