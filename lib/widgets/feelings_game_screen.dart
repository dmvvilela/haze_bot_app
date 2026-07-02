import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/feelings_game_cubit.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';
import 'robot_face_widget.dart';

/// The feelings game: Haze acts an emotion, the player names it.
class FeelingsGameScreen extends StatelessWidget {
  const FeelingsGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, faceState) {
        final isDark = faceState.config.isDarkTheme;
        final accent = faceState.config.eyeColor;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.grey[100],
            appBar: AppBar(
              backgroundColor: isDark ? Colors.black : Colors.grey[100],
              elevation: 0,
              title: Text(t.game.title),
              actions: [
                BlocBuilder<FeelingsGameCubit, FeelingsGameState>(
                  builder: (context, game) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        _ScorePill(
                          icon: Icons.star_rounded,
                          label: '${game.score}',
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _ScorePill(
                          icon: Icons.bolt_rounded,
                          label: '${game.streak}',
                          color: accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<FeelingsGameCubit, FeelingsGameState>(
                builder: (context, game) {
                  final gameCubit = context.read<FeelingsGameCubit>();
                  return Column(
                    children: [
                      // The face is display-only here — tapping it would let
                      // the player cycle expressions and skip the guessing.
                      Expanded(
                        child: Center(
                          child: AbsorbPointer(child: const RobotFaceWidget()),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              game.celebrating
                                  ? t.game.correct(
                                      name: emotionName(game.target),
                                    )
                                  : (game.misses.isEmpty
                                        ? t.game.prompt
                                        : t.game.try_again),
                              key: ValueKey(
                                '${game.round}-${game.celebrating}-${game.misses.length}',
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: game.celebrating ? accent : null,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final option in game.options)
                              _EmotionChip(
                                label: emotionName(option),
                                accent: accent,
                                state: game.celebrating
                                    ? (option == game.target
                                          ? _ChipState.correct
                                          : _ChipState.disabled)
                                    : (game.misses.contains(option)
                                          ? _ChipState.missed
                                          : _ChipState.ready),
                                onPressed: () => gameCubit.guess(option),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChipState { ready, missed, correct, disabled }

class _EmotionChip extends StatelessWidget {
  final String label;
  final Color accent;
  final _ChipState state;
  final VoidCallback onPressed;

  const _EmotionChip({
    required this.label,
    required this.accent,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (state) {
      _ChipState.correct => (accent, Colors.black87),
      _ChipState.ready => (colors.surfaceContainerHighest, colors.onSurface),
      _ => (
        colors.surfaceContainerHighest.withValues(alpha: 0.35),
        colors.onSurface.withValues(alpha: 0.3),
      ),
    };
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: state == _ChipState.missed ? 0.55 : 1,
      child: FilledButton(
        onPressed: state == _ChipState.ready ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
