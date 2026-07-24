import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chemistry/chemistry.dart';
import '../cubits/mix_game_cubit.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import '../services/sound_service.dart';
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
  Timer? _refresh;
  Timer? _reactionTimer;
  _LabReaction? _reaction;

  @override
  void initState() {
    super.initState();
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
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.grey[100],
            appBar: AppBar(
              backgroundColor: isDark ? Colors.black : Colors.grey[100],
              elevation: 0,
              title: Text(t.lab.title),
              actions: [
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
                  _ChallengeArea(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _LabReaction { boop, cuddle }

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

/// Free play shows what Haze feels; challenge mode shows what to make it
/// feel, how close the mix is, and the running score.
class _ChallengeArea extends StatelessWidget {
  final EmotionVector emotions;
  final Color accent;
  final _LabReaction? reaction;

  const _ChallengeArea({
    required this.emotions,
    required this.accent,
    required this.reaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MixGameCubit, MixGameState>(
      builder: (context, game) {
        final gameCubit = context.read<MixGameCubit>();
        switch (game.phase) {
          case MixPhase.idle:
            return Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    switch (reaction) {
                      _LabReaction.boop => t.lab.boop_reaction,
                      _LabReaction.cuddle => t.lab.cuddle_reaction,
                      null => t.lab.feeling_now(
                        name: mixEmotionLabel(emotions.dominant),
                      ),
                    },
                    key: ValueKey(reaction),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: gameCubit.startChallenge,
                  icon: const Icon(Icons.emoji_events_outlined, size: 20),
                  label: Text(t.lab.challenge.start),
                ),
              ],
            );
          case MixPhase.playing:
          case MixPhase.celebrating:
            final name = mixEmotionLabel(game.target);
            final solved = game.phase == MixPhase.celebrating;
            final progress = (emotions[game.target] / mixThreshold(game.target))
                .clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            solved
                                ? t.lab.challenge.solved(name: name)
                                : game.shifted
                                ? t.lab.challenge.shifted(name: name)
                                : t.lab.challenge.target(name: name),
                            key: ValueKey('${game.round}-$solved'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: solved ? accent : null,
                            ),
                          ),
                        ),
                      ),
                      _ScorePill(
                        icon: Icons.star_rounded,
                        label: '${game.score}',
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      _ScorePill(
                        icon: Icons.bolt_rounded,
                        label: '${game.streak}',
                        color: accent,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: t.lab.challenge.stop,
                        onPressed: gameCubit.stopChallenge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      color: solved ? accent : accent.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _ScorePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ScorePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
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
              '${mixEmotionLabel(entry.key)} ${(entry.value * 100).round()}%',
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
