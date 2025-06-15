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
  });

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
  String toString() {
    return 'RobotFaceState(config: $config, isPressed: $isPressed, isBlinking: $isBlinking, showControls: $showControls)';
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
                other.showControls == showControls));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, config, isPressed, isBlinking, showControls);

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
  }) = _$RobotFaceStateImpl;

  @override
  RobotConfig get config;
  @override
  bool get isPressed;
  @override
  bool get isBlinking;
  @override
  bool get showControls;

  /// Create a copy of RobotFaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RobotFaceStateImplCopyWith<_$RobotFaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
