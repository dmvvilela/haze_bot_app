import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chemistry/chemistry.dart';
import '../cubits/mix_game_cubit.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import '../services/sound_service.dart';
import '../services/haze_brain.dart';
import 'ai_consent_dialog.dart';
import 'robot_face_widget.dart';

/// The Haze Lab: a live window into the neurochemistry behind the face.
///
/// The top half is Haze itself (fully interactive — poke it, cuddle it, and
/// watch the chemistry move). Below are the eight chemical bars and the
/// emotion mix they project to. Tapping a chemical administers a tiny dose,
/// which is the whole lesson: feelings aren't picked from a list, they're
/// mixed.
class HazeLabScreen extends StatefulWidget {
  const HazeLabScreen({super.key});

  @override
  State<HazeLabScreen> createState() => _HazeLabScreenState();
}

class _HazeLabScreenState extends State<HazeLabScreen> {
  late final RobotFaceCubit _robot;
  Timer? _refresh;
  Timer? _reactionTimer;
  _LabReaction? _reaction;

  @override
  void initState() {
    super.initState();
    _robot = context.read<RobotFaceCubit>()..enterLab();
    // Chemistry drifts continuously; poll it at a UI-friendly rate.
    _refresh = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _reactionTimer?.cancel();
    _robot.leaveLab();
    super.dispose();
  }

  void _showReaction(_LabReaction reaction) {
    _reactionTimer?.cancel();
    setState(() => _reaction = reaction);
    _reactionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _reaction = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, faceState) {
        final cubit = context.read<RobotFaceCubit>();
        final isDark = faceState.config.isDarkTheme;
        final accent = faceState.config.eyeColor;
        final levels = cubit.mood.levels();
        final emotions = cubit.mood.emotions();
        final game = context.watch<MixGameCubit>().state;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.grey[100],
            appBar: AppBar(
              backgroundColor: isDark ? Colors.black : Colors.grey[100],
              elevation: 0,
              title: Text(t.lab.title),
              bottom: game.phase == MixPhase.idle
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(54),
                      child: _ChallengeBanner(
                        game: game,
                        emotions: emotions,
                        accent: accent,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    game.phase == MixPhase.idle
                        ? Icons.emoji_events_outlined
                        : Icons.emoji_events,
                  ),
                  color: game.phase == MixPhase.idle ? null : accent,
                  tooltip: game.phase == MixPhase.idle
                      ? t.lab.challenge.start
                      : t.lab.challenge.active,
                  onPressed: () => _showChallengeSheet(context),
                ),
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  tooltip: t.lab.reset,
                  onPressed: () {
                    cubit.mood.resetToBaseline();
                    cubit.sounds.play(HazeSound.curious);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: RobotFaceWidget(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        cubit.labBoop();
                        _showReaction(_LabReaction.boop);
                      },
                      onLongPress: () {
                        cubit.cuddle();
                        _showReaction(_LabReaction.cuddle);
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MoodSummary(
                    emotions: emotions,
                    accent: accent,
                    reaction: _reaction,
                  ),
                  const SizedBox(height: 8),
                  _EmotionMixRow(emotions: emotions, accent: accent),
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      children: [
                        for (final chem in Chemical.values)
                          _ChemicalBar(
                            chemical: chem,
                            level: levels[chem]!,
                            baseline: cubit.mood.baselines()[chem]!,
                            onDose: (delta) {
                              HapticFeedback.lightImpact();
                              cubit.mood.dose(chem, delta);
                              cubit.sounds.play(HazeSound.poke);
                              // Dosing counts as playing with Haze — keep the
                              // idle-sleep timer from firing mid-experiment.
                              cubit.startSecretInteractions();
                            },
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            t.lab.hint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 6, 20, 12),
                    child: _LabEventComposer(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChallengeSheet(BuildContext context) {
    final gameCubit = context.read<MixGameCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) =>
          BlocProvider.value(value: gameCubit, child: const _ChallengeSheet()),
    );
  }
}

enum _LabReaction { boop, cuddle }

class _ChallengeBanner extends StatelessWidget {
  final MixGameState game;
  final EmotionVector emotions;
  final Color accent;

  const _ChallengeBanner({
    required this.game,
    required this.emotions,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final solved = game.phase == MixPhase.celebrating;
    final name = _emotionLabel(game.target);
    final progress = (emotions[game.target] / mixThreshold(game.target)).clamp(
      0.0,
      1.0,
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 12, 8),
        child: Row(
          children: [
            Icon(
              solved ? Icons.check_circle : Icons.science_outlined,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solved
                        ? t.lab.challenge.solved(name: name)
                        : t.lab.challenge.target(name: name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: accent,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: t.lab.challenge.stop,
              onPressed: context.read<MixGameCubit>().stopChallenge,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeSheet extends StatelessWidget {
  const _ChallengeSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MixGameCubit, MixGameState>(
      builder: (context, game) {
        final cubit = context.read<MixGameCubit>();
        final active = game.phase != MixPhase.idle;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  t.lab.challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  active
                      ? t.lab.challenge.current(
                          name: _emotionLabel(game.target),
                        )
                      : t.lab.challenge.explanation,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: active
                      ? OutlinedButton.icon(
                          onPressed: () {
                            cubit.stopChallenge();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: Text(t.lab.challenge.stop),
                        )
                      : FilledButton.icon(
                          onPressed: () {
                            cubit.startChallenge();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(t.lab.challenge.start),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LabEventComposer extends StatefulWidget {
  const _LabEventComposer();

  @override
  State<_LabEventComposer> createState() => _LabEventComposerState();
}

class _LabEventComposerState extends State<_LabEventComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final cubit = context.read<RobotFaceCubit>();

    void respond() {
      cubit.talkToHaze(text);
      _controller.clear();
    }

    if (cubit.state.aiConsent == AiConsent.unknown) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AiConsentDialog(onResolved: respond),
        ),
      );
    } else {
      respond();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      buildWhen: (previous, current) =>
          previous.isLoadingAI != current.isLoadingAI ||
          previous.chemistryReaction != current.chemistryReaction,
      builder: (context, state) {
        return Column(
          children: [
            TextField(
              controller: _controller,
              enabled: !state.isLoadingAI,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: t.lab.tell_haze,
                prefixIcon: const Icon(Icons.auto_awesome, size: 20),
                suffixIcon: state.isLoadingAI
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: t.lab.send,
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                isDense: true,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: state.chemistryReaction.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        state.chemistryReaction,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

Color _chemicalColor(Chemical chem) => switch (chem) {
  Chemical.dopamine => const Color(0xFFFFD54F),
  Chemical.serotonin => const Color(0xFFFF9800),
  Chemical.oxytocin => const Color(0xFFF48FB1),
  Chemical.testosterone => const Color(0xFFEF5350),
  Chemical.cortisol => const Color(0xFFAB47BC),
  Chemical.adrenaline => const Color(0xFF29B6F6),
  Chemical.endorphins => const Color(0xFF66BB6A),
  Chemical.gaba => const Color(0xFF7986CB),
};

String _chemicalName(Chemical chem) => switch (chem) {
  Chemical.dopamine => t.lab.chemicals.dopamine.name,
  Chemical.serotonin => t.lab.chemicals.serotonin.name,
  Chemical.oxytocin => t.lab.chemicals.oxytocin.name,
  Chemical.testosterone => t.lab.chemicals.testosterone.name,
  Chemical.cortisol => t.lab.chemicals.cortisol.name,
  Chemical.adrenaline => t.lab.chemicals.adrenaline.name,
  Chemical.endorphins => t.lab.chemicals.endorphins.name,
  Chemical.gaba => t.lab.chemicals.gaba.name,
};

String _chemicalTag(Chemical chem) => switch (chem) {
  Chemical.dopamine => t.lab.chemicals.dopamine.tag,
  Chemical.serotonin => t.lab.chemicals.serotonin.tag,
  Chemical.oxytocin => t.lab.chemicals.oxytocin.tag,
  Chemical.testosterone => t.lab.chemicals.testosterone.tag,
  Chemical.cortisol => t.lab.chemicals.cortisol.tag,
  Chemical.adrenaline => t.lab.chemicals.adrenaline.tag,
  Chemical.endorphins => t.lab.chemicals.endorphins.tag,
  Chemical.gaba => t.lab.chemicals.gaba.tag,
};

class _MoodSummary extends StatelessWidget {
  final EmotionVector emotions;
  final Color accent;
  final _LabReaction? reaction;

  const _MoodSummary({
    required this.emotions,
    required this.accent,
    required this.reaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Text(
          switch (reaction) {
            _LabReaction.boop => t.lab.boop_reaction,
            _LabReaction.cuddle => t.lab.cuddle_reaction,
            null => t.lab.feeling_now(name: _emotionLabel(emotions.dominant)),
          },
          key: ValueKey(reaction),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// The strongest few emotions as little labeled pills, so kids see a *mix*
/// ("mostly calm, a bit excited"), never a single switched-on state.
class _EmotionMixRow extends StatelessWidget {
  final EmotionVector emotions;
  final Color accent;

  const _EmotionMixRow({required this.emotions, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final top = emotions.ranked().take(4).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final entry in top)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: 0.10 + 0.45 * entry.value.clamp(0.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_emotionLabel(entry.key)} ${(entry.value * 100).round()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
      ],
    );
  }
}

String _emotionLabel(Emotion emotion) => switch (emotion) {
  Emotion.happiness => t.lab.emotions.happiness,
  Emotion.excitement => t.lab.emotions.excitement,
  Emotion.anger => t.lab.emotions.anger,
  Emotion.calm => t.lab.emotions.calm,
  Emotion.bonding => t.lab.emotions.bonding,
  Emotion.anxiety => t.lab.emotions.anxiety,
  Emotion.sadness => t.lab.emotions.sadness,
  Emotion.euphoria => t.lab.emotions.euphoria,
};

class _ChemicalBar extends StatelessWidget {
  final Chemical chemical;
  final double level;
  final double baseline;

  /// Called with +0.2 (tap anywhere / plus) or -0.2 (minus button).
  final void Function(double delta) onDose;

  const _ChemicalBar({
    required this.chemical,
    required this.level,
    required this.baseline,
    required this.onDose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = _chemicalColor(chemical);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onDose(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 118,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chemicalName(chemical),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _chemicalTag(chemical),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 14,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      // Track
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      // Live level
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: constraints.maxWidth * level.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      // Resting-level notch: where this chemical settles.
                      Positioned(
                        left: (constraints.maxWidth * baseline.clamp(0.0, 1.0))
                            .clamp(0.0, constraints.maxWidth - 2),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: colors.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 42,
              child: Text(
                '${(level * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkResponse(
              radius: 18,
              onTap: () => onDose(-0.2),
              child: Icon(
                Icons.remove_circle_outline,
                size: 18,
                color: colors.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(width: 8),
            InkResponse(
              radius: 18,
              onTap: () => onDose(0.2),
              child: Icon(Icons.add_circle_outline, size: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
