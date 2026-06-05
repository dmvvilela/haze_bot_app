import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/robot_face_cubit.dart';
import '../services/haze_brain.dart';

class TimerDialog extends StatefulWidget {
  const TimerDialog({super.key});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  int _selectedMinutes = 5;
  final List<int> _presetMinutes = [1, 5, 10, 15, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        final timerActive = state.timerSeconds > 0 || state.isTimerRunning;
        final calmTimer =
            state.personality == HazePersonality.sleepy ||
            state.personality == HazePersonality.zen ||
            state.personality == HazePersonality.meditative;
        final paused = timerActive && !state.isTimerRunning;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                calmTimer ? Icons.self_improvement : Icons.timer,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(calmTimer ? 'Meditation Timer' : 'Focus Timer'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!timerActive) ...[
                const Text('Select timer duration:'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetMinutes.map((minutes) {
                    final isSelected = minutes == _selectedMinutes;
                    return FilterChip(
                      label: Text('${minutes}m'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMinutes = minutes;
                        });
                      },
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Timer is running - show current status
                Column(
                  children: [
                    Text(
                      paused ? 'Timer Paused' : 'Timer Running',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimer(state.timerSeconds),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ),
                    if (state.aiMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.smart_toy, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.aiMessage,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (!timerActive) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RobotFaceCubit>().startTimer(_selectedMinutes);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: () {
                  context.read<RobotFaceCubit>().stopTimer();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (paused) {
                    context.read<RobotFaceCubit>().resumeTimer();
                  } else {
                    context.read<RobotFaceCubit>().pauseTimer();
                  }
                },
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                label: Text(paused ? 'Resume' : 'Pause'),
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
