import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../i18n/strings.g.dart';
import '../models/robot_config.dart';
import '../services/sound_service.dart';
import 'robot_face_cubit.dart';

/// The emotion word shown on game chips and spoken in praise lines.
String emotionName(RobotExpression expression) => switch (expression) {
  RobotExpression.happy => t.emotion_names.happy,
  RobotExpression.surprised => t.emotion_names.surprised,
  RobotExpression.sleepy => t.emotion_names.sleepy,
  RobotExpression.excited => t.emotion_names.excited,
  RobotExpression.confused => t.emotion_names.confused,
  RobotExpression.love => t.emotion_names.love,
  RobotExpression.angry => t.emotion_names.angry,
  RobotExpression.winking => t.emotion_names.winking,
  RobotExpression.sad => t.emotion_names.sad,
  RobotExpression.scared => t.emotion_names.scared,
};

class FeelingsGameState {
  final int score;
  final int streak;
  final int round;
  final RobotExpression target;
  final List<RobotExpression> options;
  final Set<RobotExpression> misses; // wrong picks this round, dimmed out
  final bool celebrating;

  const FeelingsGameState({
    this.score = 0,
    this.streak = 0,
    this.round = 0,
    this.target = RobotExpression.happy,
    this.options = const [],
    this.misses = const {},
    this.celebrating = false,
  });

  FeelingsGameState copyWith({
    int? score,
    int? streak,
    int? round,
    RobotExpression? target,
    List<RobotExpression>? options,
    Set<RobotExpression>? misses,
    bool? celebrating,
  }) {
    return FeelingsGameState(
      score: score ?? this.score,
      streak: streak ?? this.streak,
      round: round ?? this.round,
      target: target ?? this.target,
      options: options ?? this.options,
      misses: misses ?? this.misses,
      celebrating: celebrating ?? this.celebrating,
    );
  }
}

/// "How does Haze feel?" — Haze makes a face, the player picks the matching
/// emotion word. Wrong picks just dim the chip so kids can keep trying;
/// correct picks celebrate, then the next round starts on its own.
class FeelingsGameCubit extends Cubit<FeelingsGameState> {
  final RobotFaceCubit _robot;
  final math.Random _random;
  Timer? _nextRoundTimer;

  FeelingsGameCubit(this._robot, {math.Random? random})
    : _random = random ?? math.Random(),
      super(const FeelingsGameState()) {
    _robot.sounds.play(HazeSound.hello);
    _startRound();
  }

  void _startRound() {
    // Never repeat the previous face, and grow to 4 choices once the player
    // is on a roll.
    final pool = [...RobotExpression.values];
    if (state.round > 0) pool.remove(state.target);
    pool.shuffle(_random);
    final target = pool.first;
    final optionCount = state.streak >= 5 ? 4 : 3;
    final options = [target, ...pool.skip(1).take(optionCount - 1)]
      ..shuffle(_random);

    _robot.showExpression(target);
    emit(
      state.copyWith(
        round: state.round + 1,
        target: target,
        options: options,
        misses: const {},
        celebrating: false,
      ),
    );
  }

  void guess(RobotExpression choice) {
    if (state.celebrating || state.misses.contains(choice)) return;

    if (choice == state.target) {
      final streak = state.streak + 1;
      // Escalating rewards: normal ding, a proud little hum at 3 in a row,
      // the full arpeggio at every 5 — and the face climbs the same ladder.
      _robot.sounds.play(switch (streak) {
        _ when streak % 5 == 0 => HazeSound.win,
        3 => HazeSound.proud,
        _ => HazeSound.correct,
      });
      _robot.showExpression(switch (streak) {
        _ when streak % 5 == 0 => RobotExpression.love,
        _ when streak >= 3 => RobotExpression.excited,
        _ => RobotExpression.happy,
      });
      _robot.speakLine(
        '${t.game.correct(name: emotionName(choice))} '
        '${t.game.praise[_random.nextInt(t.game.praise.length)]}',
        emotion: RobotExpression.excited,
      );
      emit(
        state.copyWith(
          score: state.score + 1,
          streak: streak,
          celebrating: true,
        ),
      );
      _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
        if (!isClosed) _startRound();
      });
    } else {
      _robot.sounds.play(HazeSound.wrong);
      emit(state.copyWith(misses: {...state.misses, choice}, streak: 0));
    }
  }

  @override
  Future<void> close() {
    _nextRoundTimer?.cancel();
    return super.close();
  }
}
