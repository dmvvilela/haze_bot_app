// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'robot_face_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RobotFaceState {
  RobotConfig get config => throw _privateConstructorUsedError;
  bool get isPressed => throw _privateConstructorUsedError;
  bool get isBlinking => throw _privateConstructorUsedError;
  bool get showControls => throw _privateConstructorUsedError;
  bool get isTimerRunning => throw _privateConstructorUsedError;
  int get timerSeconds => throw _privateConstructorUsedError;
  String get aiMessage => throw _privateConstructorUsedError;
  bool get isLoadingAI => throw _privateConstructorUsedError;
  bool get isSpeaking => throw _privateConstructorUsedError;
  MimicStatus get mimicStatus => throw _privateConstructorUsedError;
  bool get keepScreenAwake => throw _privateConstructorUsedError;
  BrainStatus get brainStatus => throw _privateConstructorUsedError;
  int get downloadProgress => throw _privateConstructorUsedError;
  AiConsent get aiConsent => throw _privateConstructorUsedError;
  HazePersonality get personality => throw _privateConstructorUsedError;
  List<TtsVoiceOption> get ttsVoiceOptions =>
      throw _privateConstructorUsedError;
  String? get selectedTtsVoiceId => throw _privateConstructorUsedError;

  /// Where the user's finger is on the face (normalized -1..1 from center),
  /// while they're dragging. The eyes follow it; null returns to idle gaze.
  Offset? get lookTarget => throw _privateConstructorUsedError;

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RobotFaceStateCopyWith<RobotFaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RobotFaceStateCopyWith<$Res> {
  factory $RobotFaceStateCopyWith(
    RobotFaceState value,
    $Res Function(RobotFaceState) then,
  ) = _$RobotFaceStateCopyWithImpl<$Res, RobotFaceState>;
  @useResult
  $Res call({
    RobotConfig config,
    bool isPressed,
    bool isBlinking,
    bool showControls,
    bool isTimerRunning,
    int timerSeconds,
    String aiMessage,
    bool isLoadingAI,
    bool isSpeaking,
    MimicStatus mimicStatus,
    bool keepScreenAwake,
    BrainStatus brainStatus,
    int downloadProgress,
    AiConsent aiConsent,
    HazePersonality personality,
    List<TtsVoiceOption> ttsVoiceOptions,
    String? selectedTtsVoiceId,
    Offset? lookTarget,
  });

  $RobotConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$RobotFaceStateCopyWithImpl<$Res, $Val extends RobotFaceState>
    implements $RobotFaceStateCopyWith<$Res> {
  _$RobotFaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? isPressed = null,
    Object? isBlinking = null,
    Object? showControls = null,
    Object? isTimerRunning = null,
    Object? timerSeconds = null,
    Object? aiMessage = null,
    Object? isLoadingAI = null,
    Object? isSpeaking = null,
    Object? mimicStatus = null,
    Object? keepScreenAwake = null,
    Object? brainStatus = null,
    Object? downloadProgress = null,
    Object? aiConsent = null,
    Object? personality = null,
    Object? ttsVoiceOptions = null,
    Object? selectedTtsVoiceId = freezed,
    Object? lookTarget = freezed,
  }) {
    return _then(
      _value.copyWith(
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as RobotConfig,
            isPressed: null == isPressed
                ? _value.isPressed
                : isPressed // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBlinking: null == isBlinking
                ? _value.isBlinking
                : isBlinking // ignore: cast_nullable_to_non_nullable
                      as bool,
            showControls: null == showControls
                ? _value.showControls
                : showControls // ignore: cast_nullable_to_non_nullable
                      as bool,
            isTimerRunning: null == isTimerRunning
                ? _value.isTimerRunning
                : isTimerRunning // ignore: cast_nullable_to_non_nullable
                      as bool,
            timerSeconds: null == timerSeconds
                ? _value.timerSeconds
                : timerSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            aiMessage: null == aiMessage
                ? _value.aiMessage
                : aiMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            isLoadingAI: null == isLoadingAI
                ? _value.isLoadingAI
                : isLoadingAI // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSpeaking: null == isSpeaking
                ? _value.isSpeaking
                : isSpeaking // ignore: cast_nullable_to_non_nullable
                      as bool,
            mimicStatus: null == mimicStatus
                ? _value.mimicStatus
                : mimicStatus // ignore: cast_nullable_to_non_nullable
                      as MimicStatus,
            keepScreenAwake: null == keepScreenAwake
                ? _value.keepScreenAwake
                : keepScreenAwake // ignore: cast_nullable_to_non_nullable
                      as bool,
            brainStatus: null == brainStatus
                ? _value.brainStatus
                : brainStatus // ignore: cast_nullable_to_non_nullable
                      as BrainStatus,
            downloadProgress: null == downloadProgress
                ? _value.downloadProgress
                : downloadProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            aiConsent: null == aiConsent
                ? _value.aiConsent
                : aiConsent // ignore: cast_nullable_to_non_nullable
                      as AiConsent,
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as HazePersonality,
            ttsVoiceOptions: null == ttsVoiceOptions
                ? _value.ttsVoiceOptions
                : ttsVoiceOptions // ignore: cast_nullable_to_non_nullable
                      as List<TtsVoiceOption>,
            selectedTtsVoiceId: freezed == selectedTtsVoiceId
                ? _value.selectedTtsVoiceId
                : selectedTtsVoiceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lookTarget: freezed == lookTarget
                ? _value.lookTarget
                : lookTarget // ignore: cast_nullable_to_non_nullable
                      as Offset?,
          )
          as $Val,
    );
  }

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RobotConfigCopyWith<$Res> get config {
    return $RobotConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RobotFaceStateImplCopyWith<$Res>
    implements $RobotFaceStateCopyWith<$Res> {
  factory _$$RobotFaceStateImplCopyWith(
    _$RobotFaceStateImpl value,
    $Res Function(_$RobotFaceStateImpl) then,
  ) = __$$RobotFaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RobotConfig config,
    bool isPressed,
    bool isBlinking,
    bool showControls,
    bool isTimerRunning,
    int timerSeconds,
    String aiMessage,
    bool isLoadingAI,
    bool isSpeaking,
    MimicStatus mimicStatus,
    bool keepScreenAwake,
    BrainStatus brainStatus,
    int downloadProgress,
    AiConsent aiConsent,
    HazePersonality personality,
    List<TtsVoiceOption> ttsVoiceOptions,
    String? selectedTtsVoiceId,
    Offset? lookTarget,
  });

  @override
  $RobotConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$RobotFaceStateImplCopyWithImpl<$Res>
    extends _$RobotFaceStateCopyWithImpl<$Res, _$RobotFaceStateImpl>
    implements _$$RobotFaceStateImplCopyWith<$Res> {
  __$$RobotFaceStateImplCopyWithImpl(
    _$RobotFaceStateImpl _value,
    $Res Function(_$RobotFaceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? isPressed = null,
    Object? isBlinking = null,
    Object? showControls = null,
    Object? isTimerRunning = null,
    Object? timerSeconds = null,
    Object? aiMessage = null,
    Object? isLoadingAI = null,
    Object? isSpeaking = null,
    Object? mimicStatus = null,
    Object? keepScreenAwake = null,
    Object? brainStatus = null,
    Object? downloadProgress = null,
    Object? aiConsent = null,
    Object? personality = null,
    Object? ttsVoiceOptions = null,
    Object? selectedTtsVoiceId = freezed,
    Object? lookTarget = freezed,
  }) {
    return _then(
      _$RobotFaceStateImpl(
        config: null == config
            ? _value.config
            : config // ignore: cast_nullable_to_non_nullable
                  as RobotConfig,
        isPressed: null == isPressed
            ? _value.isPressed
            : isPressed // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBlinking: null == isBlinking
            ? _value.isBlinking
            : isBlinking // ignore: cast_nullable_to_non_nullable
                  as bool,
        showControls: null == showControls
            ? _value.showControls
            : showControls // ignore: cast_nullable_to_non_nullable
                  as bool,
        isTimerRunning: null == isTimerRunning
            ? _value.isTimerRunning
            : isTimerRunning // ignore: cast_nullable_to_non_nullable
                  as bool,
        timerSeconds: null == timerSeconds
            ? _value.timerSeconds
            : timerSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        aiMessage: null == aiMessage
            ? _value.aiMessage
            : aiMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        isLoadingAI: null == isLoadingAI
            ? _value.isLoadingAI
            : isLoadingAI // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSpeaking: null == isSpeaking
            ? _value.isSpeaking
            : isSpeaking // ignore: cast_nullable_to_non_nullable
                  as bool,
        mimicStatus: null == mimicStatus
            ? _value.mimicStatus
            : mimicStatus // ignore: cast_nullable_to_non_nullable
                  as MimicStatus,
        keepScreenAwake: null == keepScreenAwake
            ? _value.keepScreenAwake
            : keepScreenAwake // ignore: cast_nullable_to_non_nullable
                  as bool,
        brainStatus: null == brainStatus
            ? _value.brainStatus
            : brainStatus // ignore: cast_nullable_to_non_nullable
                  as BrainStatus,
        downloadProgress: null == downloadProgress
            ? _value.downloadProgress
            : downloadProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        aiConsent: null == aiConsent
            ? _value.aiConsent
            : aiConsent // ignore: cast_nullable_to_non_nullable
                  as AiConsent,
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as HazePersonality,
        ttsVoiceOptions: null == ttsVoiceOptions
            ? _value._ttsVoiceOptions
            : ttsVoiceOptions // ignore: cast_nullable_to_non_nullable
                  as List<TtsVoiceOption>,
        selectedTtsVoiceId: freezed == selectedTtsVoiceId
            ? _value.selectedTtsVoiceId
            : selectedTtsVoiceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lookTarget: freezed == lookTarget
            ? _value.lookTarget
            : lookTarget // ignore: cast_nullable_to_non_nullable
                  as Offset?,
      ),
    );
  }
}

/// @nodoc

class _$RobotFaceStateImpl implements _RobotFaceState {
  const _$RobotFaceStateImpl({
    this.config = const RobotConfig(),
    this.isPressed = false,
    this.isBlinking = false,
    this.showControls = true,
    this.isTimerRunning = false,
    this.timerSeconds = 0,
    this.aiMessage = '',
    this.isLoadingAI = false,
    this.isSpeaking = false,
    this.mimicStatus = MimicStatus.idle,
    this.keepScreenAwake = false,
    this.brainStatus = BrainStatus.idle,
    this.downloadProgress = 0,
    this.aiConsent = AiConsent.unknown,
    this.personality = HazePersonality.playful,
    final List<TtsVoiceOption> ttsVoiceOptions = const [],
    this.selectedTtsVoiceId,
    this.lookTarget,
  }) : _ttsVoiceOptions = ttsVoiceOptions;

  @override
  @JsonKey()
  final RobotConfig config;
  @override
  @JsonKey()
  final bool isPressed;
  @override
  @JsonKey()
  final bool isBlinking;
  @override
  @JsonKey()
  final bool showControls;
  @override
  @JsonKey()
  final bool isTimerRunning;
  @override
  @JsonKey()
  final int timerSeconds;
  @override
  @JsonKey()
  final String aiMessage;
  @override
  @JsonKey()
  final bool isLoadingAI;
  @override
  @JsonKey()
  final bool isSpeaking;
  @override
  @JsonKey()
  final MimicStatus mimicStatus;
  @override
  @JsonKey()
  final bool keepScreenAwake;
  @override
  @JsonKey()
  final BrainStatus brainStatus;
  @override
  @JsonKey()
  final int downloadProgress;
  @override
  @JsonKey()
  final AiConsent aiConsent;
  @override
  @JsonKey()
  final HazePersonality personality;
  final List<TtsVoiceOption> _ttsVoiceOptions;
  @override
  @JsonKey()
  List<TtsVoiceOption> get ttsVoiceOptions {
    if (_ttsVoiceOptions is EqualUnmodifiableListView) return _ttsVoiceOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ttsVoiceOptions);
  }

  @override
  final String? selectedTtsVoiceId;

  /// Where the user's finger is on the face (normalized -1..1 from center),
  /// while they're dragging. The eyes follow it; null returns to idle gaze.
  @override
  final Offset? lookTarget;

  @override
  String toString() {
    return 'RobotFaceState(config: $config, isPressed: $isPressed, isBlinking: $isBlinking, showControls: $showControls, isTimerRunning: $isTimerRunning, timerSeconds: $timerSeconds, aiMessage: $aiMessage, isLoadingAI: $isLoadingAI, isSpeaking: $isSpeaking, mimicStatus: $mimicStatus, keepScreenAwake: $keepScreenAwake, brainStatus: $brainStatus, downloadProgress: $downloadProgress, aiConsent: $aiConsent, personality: $personality, ttsVoiceOptions: $ttsVoiceOptions, selectedTtsVoiceId: $selectedTtsVoiceId, lookTarget: $lookTarget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RobotFaceStateImpl &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.isPressed, isPressed) ||
                other.isPressed == isPressed) &&
            (identical(other.isBlinking, isBlinking) ||
                other.isBlinking == isBlinking) &&
            (identical(other.showControls, showControls) ||
                other.showControls == showControls) &&
            (identical(other.isTimerRunning, isTimerRunning) ||
                other.isTimerRunning == isTimerRunning) &&
            (identical(other.timerSeconds, timerSeconds) ||
                other.timerSeconds == timerSeconds) &&
            (identical(other.aiMessage, aiMessage) ||
                other.aiMessage == aiMessage) &&
            (identical(other.isLoadingAI, isLoadingAI) ||
                other.isLoadingAI == isLoadingAI) &&
            (identical(other.isSpeaking, isSpeaking) ||
                other.isSpeaking == isSpeaking) &&
            (identical(other.mimicStatus, mimicStatus) ||
                other.mimicStatus == mimicStatus) &&
            (identical(other.keepScreenAwake, keepScreenAwake) ||
                other.keepScreenAwake == keepScreenAwake) &&
            (identical(other.brainStatus, brainStatus) ||
                other.brainStatus == brainStatus) &&
            (identical(other.downloadProgress, downloadProgress) ||
                other.downloadProgress == downloadProgress) &&
            (identical(other.aiConsent, aiConsent) ||
                other.aiConsent == aiConsent) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            const DeepCollectionEquality().equals(
              other._ttsVoiceOptions,
              _ttsVoiceOptions,
            ) &&
            (identical(other.selectedTtsVoiceId, selectedTtsVoiceId) ||
                other.selectedTtsVoiceId == selectedTtsVoiceId) &&
            (identical(other.lookTarget, lookTarget) ||
                other.lookTarget == lookTarget));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    config,
    isPressed,
    isBlinking,
    showControls,
    isTimerRunning,
    timerSeconds,
    aiMessage,
    isLoadingAI,
    isSpeaking,
    mimicStatus,
    keepScreenAwake,
    brainStatus,
    downloadProgress,
    aiConsent,
    personality,
    const DeepCollectionEquality().hash(_ttsVoiceOptions),
    selectedTtsVoiceId,
    lookTarget,
  );

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RobotFaceStateImplCopyWith<_$RobotFaceStateImpl> get copyWith =>
      __$$RobotFaceStateImplCopyWithImpl<_$RobotFaceStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RobotFaceState implements RobotFaceState {
  const factory _RobotFaceState({
    final RobotConfig config,
    final bool isPressed,
    final bool isBlinking,
    final bool showControls,
    final bool isTimerRunning,
    final int timerSeconds,
    final String aiMessage,
    final bool isLoadingAI,
    final bool isSpeaking,
    final MimicStatus mimicStatus,
    final bool keepScreenAwake,
    final BrainStatus brainStatus,
    final int downloadProgress,
    final AiConsent aiConsent,
    final HazePersonality personality,
    final List<TtsVoiceOption> ttsVoiceOptions,
    final String? selectedTtsVoiceId,
    final Offset? lookTarget,
  }) = _$RobotFaceStateImpl;

  @override
  RobotConfig get config;
  @override
  bool get isPressed;
  @override
  bool get isBlinking;
  @override
  bool get showControls;
  @override
  bool get isTimerRunning;
  @override
  int get timerSeconds;
  @override
  String get aiMessage;
  @override
  bool get isLoadingAI;
  @override
  bool get isSpeaking;
  @override
  MimicStatus get mimicStatus;
  @override
  bool get keepScreenAwake;
  @override
  BrainStatus get brainStatus;
  @override
  int get downloadProgress;
  @override
  AiConsent get aiConsent;
  @override
  HazePersonality get personality;
  @override
  List<TtsVoiceOption> get ttsVoiceOptions;
  @override
  String? get selectedTtsVoiceId;

  /// Where the user's finger is on the face (normalized -1..1 from center),
  /// while they're dragging. The eyes follow it; null returns to idle gaze.
  @override
  Offset? get lookTarget;

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RobotFaceStateImplCopyWith<_$RobotFaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
