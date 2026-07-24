import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../chemistry/chemistry.dart';
import '../i18n/strings.g.dart';
import '../models/robot_config.dart';
import '../services/sound_service.dart';
import 'robot_face_cubit.dart';

/// How strong a target emotion has to get before the round is won. Tuned to
/// what the chemistry can actually reach with lab doses (anger and anxiety
/// fight their own GABA brake, so they clear a slightly lower bar).
double mixThreshold(Emotion emotion) => switch (emotion) {
      Emotion.anger || Emotion.anxiety || Emotion.sadness => 0.5,
      _ => 0.55,
    };

/// Won when the target is strong enough AND at least co-dominant (top two).
/// Strict dominance would be cruel: pushing excitement inevitably drags
/// euphoria and happiness up with it — that overlap is real, not a mistake.
bool isMixSolved(EmotionVector emotions, Emotion target) {
  if (emotions[target] < mixThreshold(target)) return false;
  final ranked = emotions.ranked();
  return ranked[0].key == target || ranked[1].key == target;
}

/// Pick the next target: never the previous one, and prefer emotions with
/// real work left. If the kid somehow maxed everything, take the weakest.
Emotion pickMixTarget(
  EmotionVector emotions, {
  Emotion? previous,
  required math.Random random,
}) {
  final open = [
    for (final emotion in Emotion.values)
      if (emotion != previous &&
          emotions[emotion] < mixThreshold(emotion) - 0.1)
        emotion,
  ];
  if (open.isNotEmpty) return open[random.nextInt(open.length)];
  final ranked = emotions.ranked().reversed.toList();
  return ranked.firstWhere((e) => e.key != previous, orElse: () => ranked.first).key;
}

/// When a round would start nearly won, life happens first: soothing targets
/// get a startle to recover from, agitated targets get a mellowing wash to
/// build back out of. Regulation is half the lesson.
List<ChemicalImpulse> mixPerturbation(Emotion target) => switch (target) {
      Emotion.calm ||
      Emotion.happiness ||
      Emotion.bonding ||
      Emotion.euphoria =>
        const [
          ChemicalImpulse(Chemical.cortisol, 0.35),
          ChemicalImpulse(Chemical.adrenaline, 0.40),
          ChemicalImpulse(Chemical.serotonin, -0.10),
          ChemicalImpulse(Chemical.dopamine, -0.10),
          ChemicalImpulse(Chemical.oxytocin, -0.05),
        ],
      Emotion.excitement ||
      Emotion.anger ||
      Emotion.anxiety ||
      Emotion.sadness =>
        const [
          ChemicalImpulse(Chemical.gaba, 0.35),
          ChemicalImpulse(Chemical.serotonin, 0.10),
          ChemicalImpulse(Chemical.adrenaline, -0.25),
          ChemicalImpulse(Chemical.cortisol, -0.15),
        ],
    };

/// The face Haze celebrates a solved round with.
RobotExpression mixExpression(Emotion emotion) => switch (emotion) {
      Emotion.happiness || Emotion.calm => RobotExpression.happy,
      Emotion.excitement || Emotion.euphoria => RobotExpression.excited,
      Emotion.anger => RobotExpression.angry,
      Emotion.bonding => RobotExpression.love,
      Emotion.anxiety => RobotExpression.scared,
      Emotion.sadness => RobotExpression.sad,
    };

enum MixPhase { idle, playing, celebrating }

class MixGameState {
  final MixPhase phase;
  final Emotion target;
  final int score;
  final int streak;
  final int round;

  /// True when this round opened with a perturbation ("mood just shifted").
  final bool shifted;

  const MixGameState({
    this.phase = MixPhase.idle,
    this.target = Emotion.happiness,
    this.score = 0,
    this.streak = 0,
    this.round = 0,
    this.shifted = false,
  });

  MixGameState copyWith({
    MixPhase? phase,
    Emotion? target,
    int? score,
    int? streak,
    int? round,
    bool? shifted,
  }) {
    return MixGameState(
      phase: phase ?? this.phase,
      target: target ?? this.target,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      round: round ?? this.round,
      shifted: shifted ?? this.shifted,
    );
  }
}

/// The lab's challenge mode: Haze names a feeling, the player mixes chemicals
/// (or pokes, cuddles and shakes Haze — every real interaction moves the
/// chemistry, so they all count) until the projection reaches it.
///
/// There is no "wrong answer" path at all: the chemistry is the referee, and
/// a poll watches it cross the line — however it got there.
class MixGameCubit extends Cubit<MixGameState> {
  final RobotFaceCubit _robot;
  final math.Random _random;
  Timer? _pollTimer;
  Timer? _nextRoundTimer;

  MixGameCubit(
    this._robot, {
    math.Random? random,
    Duration pollEvery = const Duration(milliseconds: 250),
  })  : _random = random ?? math.Random(),
        super(const MixGameState()) {
    _pollTimer = Timer.periodic(pollEvery, (_) => _checkSolved());
  }

  void startChallenge() {
    if (state.phase != MixPhase.idle) return;
    _startRound();
  }

  void stopChallenge() {
    _nextRoundTimer?.cancel();
    emit(const MixGameState().copyWith(score: state.score));
  }

  void _startRound() {
    final emotions = _robot.mood.emotions();
    final target = pickMixTarget(
      emotions,
      previous: state.round == 0 ? null : state.target,
      random: _random,
    );
    var shifted = false;
    if (emotions[target] >= mixThreshold(target) - 0.15) {
      _robot.mood.applyImpulses(mixPerturbation(target));
      _robot.sounds.play(HazeSound.curious);
      shifted = true;
    }
    emit(
      state.copyWith(
        phase: MixPhase.playing,
        target: target,
        round: state.round + 1,
        shifted: shifted,
      ),
    );
  }

  void _checkSolved() {
    if (isClosed || state.phase != MixPhase.playing) return;
    if (!isMixSolved(_robot.mood.emotions(), state.target)) return;

    final streak = state.streak + 1;
    // Solving feels good for Haze too — same reward ladder as the
    // feelings game.
    _robot.mood.gameCorrect();
    if (streak % 5 == 0) _robot.mood.gameStreak();
    _robot.sounds.play(switch (streak) {
      _ when streak % 5 == 0 => HazeSound.win,
      3 => HazeSound.proud,
      _ => HazeSound.correct,
    });
    final expression = mixExpression(state.target);
    _robot.showExpression(expression);
    _robot.speakLine(
      '${t.lab.challenge.solved(name: mixEmotionLabel(state.target))} '
      '${t.game.praise[_random.nextInt(t.game.praise.length)]}',
      emotion: expression,
    );
    emit(
      state.copyWith(
        phase: MixPhase.celebrating,
        score: state.score + 1,
        streak: streak,
      ),
    );
    _nextRoundTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!isClosed && state.phase == MixPhase.celebrating) _startRound();
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _nextRoundTimer?.cancel();
    return super.close();
  }
}

/// Localized name of a chemistry emotion (shared with the lab display).
String mixEmotionLabel(Emotion emotion) => switch (emotion) {
      Emotion.happiness => t.lab.emotions.happiness,
      Emotion.excitement => t.lab.emotions.excitement,
      Emotion.anger => t.lab.emotions.anger,
      Emotion.calm => t.lab.emotions.calm,
      Emotion.bonding => t.lab.emotions.bonding,
      Emotion.anxiety => t.lab.emotions.anxiety,
      Emotion.sadness => t.lab.emotions.sadness,
      Emotion.euphoria => t.lab.emotions.euphoria,
    };
