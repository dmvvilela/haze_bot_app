part of 'robot_face_cubit.dart';

@freezed
class RobotFaceState with _$RobotFaceState {
  const factory RobotFaceState({
    @Default(RobotConfig()) RobotConfig config,
    @Default(false) bool isPressed,
    @Default(false) bool isBlinking,
    @Default(true) bool showControls,
    @Default(false) bool isTimerRunning,
    @Default(0) int timerSeconds,
    @Default('') String aiMessage,
    @Default(false) bool isLoadingAI,
    @Default(false) bool isSpeaking,
    @Default(false) bool keepScreenAwake,
    @Default(BrainStatus.idle) BrainStatus brainStatus,
    @Default(0) int downloadProgress,
    @Default(AiConsent.unknown) AiConsent aiConsent,
    @Default(HazePersonality.playful) HazePersonality personality,
    @Default([]) List<TtsVoiceOption> ttsVoiceOptions,
    String? selectedTtsVoiceId,
  }) = _RobotFaceState;
}
