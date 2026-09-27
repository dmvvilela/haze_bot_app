import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/robot_face_cubit.dart';
import '../i18n/strings.g.dart';

class TimerDialog extends StatefulWidget {
  const TimerDialog({super.key});
  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  int _selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final cubit = context.read<RobotFaceCubit>();
        final colors = Theme.of(context).colorScheme;
        final active = state.timerSeconds > 0 || state.isTimerRunning;
        final paused = active && !state.isTimerRunning;
        return AlertDialog(
          icon: Icon(
            Icons.hourglass_empty_rounded,
            color: colors.primary,
            size: 28,
          ),
          title: Text(t.home.timerTitle),
          scrollable: true,
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  active
                      ? (paused ? t.home.timerPaused : t.home.timerRunning)
                      : t.home.timerHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Text(
                  active
                      ? _format(state.timerSeconds)
                      : _format(_selectedMinutes * 60),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 24),
                if (!active)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final minutes in [1, 5, 10, 15, 25, 30, 45, 60])
                        ChoiceChip(
                          label: Text(t.home.minutes(n: minutes)),
                          selected: _selectedMinutes == minutes,
                          onSelected: (_) =>
                              setState(() => _selectedMinutes = minutes),
                        ),
                    ],
                  ),
                if (active && state.aiMessage.isNotEmpty)
                  Text(
                    state.aiMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.5),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (active) cubit.stopTimer();
                Navigator.pop(context);
              },
              child: Text(active ? t.home.stop : t.home.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!active) {
                  cubit.startTimer(_selectedMinutes);
                  Navigator.pop(context);
                } else if (paused) {
                  cubit.resumeTimer();
                } else {
                  cubit.pauseTimer();
                }
              },
              icon: Icon(active && !paused ? Icons.pause : Icons.play_arrow),
              label: Text(
                !active
                    ? t.home.start
                    : paused
                    ? t.home.resume
                    : t.home.pause,
              ),
            ),
          ],
        );
      },
    );
  }

  String _format(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
