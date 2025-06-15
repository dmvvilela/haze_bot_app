part of 'robot_face_cubit.dart';

@freezed
class RobotFaceState with _$RobotFaceState {
  const factory RobotFaceState({
    @Default(RobotConfig()) RobotConfig config,
    @Default(false) bool isPressed,
    @Default(false) bool isBlinking,
    @Default(true) bool showControls,
  }) = _RobotFaceState;
}
